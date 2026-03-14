# frozen_string_literal: true

class AnalyzerJob < ApplicationJob
  include ActiveJob::Continuable
  include PhotoHelper
  include Rails.application.routes.url_helpers

  retry_on EXIFR::MalformedJPEG, attempts: 5, wait: :polynomially_longer
  retry_on ActiveStorage::FileNotFoundError, attempts: 5, wait: :polynomially_longer
  retry_on Errno::ECONNRESET, attempts: 5, wait: :polynomially_longer

  discard_on Encoding::UndefinedConversionError
  discard_on ActiveRecord::RecordInvalid

  def perform(notice)
    @notice = notice
    step :handle_exif
    step :handle_gemini
    step :finalize
  end

  private

  def handle_exif
    @notice.photos.each do |photo|
      uri = image_url(photo)
      exif = URI.open(uri) { |data| exifer.metadata(data) }
      next if exif.blank?

      exif_data_set = @notice.data_sets.create!(data: exif, kind: :exif, keyable: photo)

      # the last or first exif is the good as any other
      coords = exif_data_set.coords
      next if coords.blank?

      if @notice.data_sets.geocoder.blank?
        result = Geocoder.search(coords)
        if result.present?
          geocoder_data_set = @notice.data_sets.create!(data: result, kind: :geocoder, keyable: photo)
          if @notice.user.from_exif?
            address = geocoder_data_set.address
            @notice.latitude = address[:latitude]
            @notice.longitude = address[:longitude]
            @notice.zip = address[:zip]
            @notice.city = address[:city]
            @notice.street = address[:street]
          end
        end
      end

      if @notice.data_sets.proximity.blank?
        result = Notice.nearest_tbnrs(coords.first, coords.last, @notice.user.id)
        if result.present?
          proximity_data_set = @notice.data_sets.create!(data: result, kind: :proximity, keyable: photo)
          if @notice.user.from_proximity?
            @notice.tbnr ||= proximity_data_set.tbnrs.first
          end
        end
      end
    end

    if @notice.user.from_exif?
      dates = @notice.dates_from_photos
      @notice.start_date ||= dates.first
      @notice.end_date ||= dates.last
    end
  end

  def handle_gemini
    return if @notice.user.no_analyzer?

    @notice.photos.each do |photo|
      uri = image_url(photo)
      result = gemini_annotator(@notice.user.analyzer).annotate_object(uri)
      next if result.blank?

      data_set = @notice.data_sets.create!(data: result, kind: :gemini, keyable: photo)

      registrations = data_set.registrations
      if registrations.present?
        apply_registrations(@notice, registrations, data_set)
        break
      end
    end
  end

  def finalize
    @notice.status = :open
    @notice.save_incomplete!
  end

  def apply_registrations(notice, registrations, data_set)
    notice.apply_favorites(registrations) if notice.user.from_history?

    if notice.user.from_recognition?
      notice.registration ||= registrations.first
      notice.brand ||= data_set.brands.first
      notice.color ||= data_set.colors.first
    end
  end

  def gemini_annotator(model = nil)
    GeminiAnnotator.new(model: model)
  end

  def image_url(photo)
    if Rails.env.development?
      photo.url
    else
      cloudflare_image_resize_url(photo.key, :default, true)
    end
  end

  def exifer
    @exifer ||= ExifAnalyzer.new
  end
end
