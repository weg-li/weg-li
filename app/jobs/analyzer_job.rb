# frozen_string_literal: true

class AnalyzerJob < ApplicationJob
  retry_on EXIFR::MalformedJPEG, attempts: 5, wait: :polynomially_longer
  retry_on ActiveStorage::FileNotFoundError,
           attempts: 5,
           wait: :polynomially_longer
  discard_on Encoding::UndefinedConversionError
  discard_on ActiveRecord::RecordInvalid

  # TODO: move me to notice
  def self.time_from_filename(filename)
    token = filename[/.*(20\d{6}_\d{6})/, 1]
    token ||= filename[/.*(20\d{2}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})/, 1]
    token ||= filename[/.*(20\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})-.*/, 1]

    return nil unless token

    begin
      Time.zone.parse(token.gsub("-", ""))
    rescue StandardError
      nil
    end
  end

  def perform(notice)
    analyze(notice)
  end

  def analyze(notice)
    handle_exif(notice)

    case annotator_backend
    when "gemini"
      handle_gemini(notice)
    when "vision"
      handle_vision(notice)
    else # "auto"
      gemini_success = handle_gemini(notice) if gemini_available?
      handle_vision(notice) unless gemini_success
    end

    notice.status = :open
    notice.save_incomplete!
  end

  private

  def handle_vision(notice)
    notice.photos.each do |photo|
      result = annotator.annotate_object(photo.key)

      if result.present?
        data_set =
          notice.data_sets.create!(
            data: result,
            kind: :google_vision,
            keyable: photo,
          )
        # skip if we got lucky
        registrations = data_set.registrations
        if registrations.present?
          apply_registrations(notice, registrations, data_set)

          break
        end
      end
    end
  end

  def apply_registrations(notice, registrations, data_set)
    notice.apply_favorites(registrations) if notice.user.from_history?

    if notice.user.from_recognition?
      notice.registration ||= registrations.first
      notice.brand ||= data_set.brands.first
      notice.color ||= data_set.colors.first
    end
  end

  def handle_gemini(notice)
    notice.photos.each do |photo|
      result = gemini_annotator.annotate_object(photo.key)
      next if result.blank?

      data_set =
        notice.data_sets.create!(
          data: result,
          kind: :gemini,
          keyable: photo,
        )

      registrations = data_set.registrations
      if registrations.present?
        apply_registrations(notice, registrations, data_set)
        return true
      end
    end

    false
  end

  def annotator_backend
    ENV.fetch("ANNOTATOR_BACKEND", "auto")
  end

  def gemini_available?
    ENV["GEMINI_API_KEY"].present?
  end

  def gemini_annotator
    @gemini_annotator ||= GeminiAnnotator.new
  end

  def annotator
    @annotator ||= Annotator.new
  end

  def handle_exif(notice)
    notice.photos.each do |photo|
      exif =
        photo.service.download_file(photo.key) { |file| exifer.metadata(file) }
      next if exif.blank?

      exif_data_set =
        notice.data_sets.create!(data: exif, kind: :exif, keyable: photo)

      # the last or first exif is the good as any other
      coords = exif_data_set.coords
      next if coords.blank?

      if notice.data_sets.geocoder.blank?
        result = Geocoder.search(coords)
        if result.present?
          geocoder_data_set =
            notice.data_sets.create!(
              data: result,
              kind: :geocoder,
              keyable: photo,
            )
          if notice.user.from_exif?
            address = geocoder_data_set.address
            notice.latitude = address[:latitude]
            notice.longitude = address[:longitude]
            notice.zip = address[:zip]
            notice.city = address[:city]
            notice.street = address[:street]
          end
        end
      end

      if notice.data_sets.proximity.blank?
        result = Notice.nearest_tbnrs(*coords)
        if result.present?
          proximity_data_set = notice.data_sets.create!(data: result, kind: :proximity, keyable: photo)
          if notice.user.from_proximity?
            notice.tbnr ||= proximity_data_set.tbnrs.first
          end
        end
      end
    end

    if notice.user.from_exif?
      dates = notice.dates_from_photos
      notice.start_date ||= dates.first
      notice.end_date ||= dates.last
    end
  end

  def exifer
    @exifer ||= ExifAnalyzer.new
  end
end
