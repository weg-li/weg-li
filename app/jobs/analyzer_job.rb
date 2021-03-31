class AnalyzerJob < ApplicationJob
  retry_on EXIFR::MalformedJPEG, attempts: 15, wait: :exponentially_longer
  retry_on ActiveStorage::FileNotFoundError, attempts: 15, wait: :exponentially_longer
  discard_on Encoding::UndefinedConversionError

  def self.time_from_filename(filename)
    token = filename[/.*(20\d{6}_\d{6})/, 1]
    token ||= filename[/.*(20\d{2}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})/, 1]

    return nil unless token
    Time.zone.parse(token.gsub('-', '')) rescue nil
  end

  def perform(notice)
    fail NotYetAnalyzedError unless notice.photos.all?(&:analyzed?)

    analyze(notice)
  end

  def analyze(notice)
    notice.status = :open

    handle_exif(notice)
    handle_vision(notice)
    handle_car_ml(notice)

    notice.save_incomplete!
  end

  private

  def handle_vision(notice)
    plates = []
    brands = []
    colors = []

    # district is only set after the geolocation so that must be done first
    prefixes = notice.district&.prefixes || notice.user.district&.prefixes || []

    notice.photos.each do |photo|
      result = annotator.annotate_object(photo.key)
      if result.present?
        notice.data_sets.create!(data: result, kind: :google_vision, keyable: photo)
        if Annotator.unsafe?(result)
          notify("safe search violated for notice #{notice.id} with photo #{photo.id} on user #{notice.user.id}: https://www.weg.li/admin/notices/#{notice.token}")
        end

        plates += Annotator.grep_text(result) { |string| Vehicle.plate?(string, prefixes: prefixes) }
        brands += Annotator.grep_text(result) { |string| Vehicle.brand?(string) }
        colors += Annotator.dominant_colors(result)
      end
    end

    most_likely_registraton = Vehicle.most_likely?(plates)
    notice.apply_favorites(most_likely_registraton)

    notice.registration ||= most_likely_registraton
    notice.brand ||= Vehicle.most_likely?(brands)
    notice.color ||= Vehicle.most_likely?(colors)
  end

  def handle_exif(notice)
    dates = []

    notice.photos.each do |photo|
      exif = photo.service.download_file(photo.key) { |file| exifer.metadata(file) }
      notice.data_sets.create!(data: exif, kind: :exif, keyable: photo)

      # the last exif is the good as any other
      notice.latitude = exif[:latitude] if exif[:latitude].to_f.positive?
      notice.longitude = exif[:longitude] if exif[:longitude].to_f.positive?

      dates << (time_from_meta(exif[:date_time]) || AnalyzerJob.time_from_filename(photo.filename.to_s))
    end
    notice.apply_dates(dates)

    notice.handle_geocoding
  end

  def handle_car_ml(notice)
    api = create_api

    photos = notice.photos.first(3)
    image_upload_response = api.analyze_image_upload_get(quantity: photos.size)
    photos.each_with_index do |photo, i|
      url = image_upload_response.google_cloud_urls[i]

      photo.service.download_file(photo.key) do |file|
        header = { 'Content-Type' => 'image/jpeg' }
        res = HTTPClient.new.put(url, header: header, body: file)
        notify("could not upload photo #{photo.id} for notice: https://www.weg.li/admin/notices/#{notice.token}") unless res.ok?
      end
    end

    response = api.analyze_image_image_token_get(image_upload_response.token)
    notice.data_sets.create!(data: response.to_json, kind: :car_ml, keyable: notice)
  end

  def create_api
    config = OpenapiClient::Configuration.new
    config.host = 'https://europe-west3-wegli-296209.cloudfunctions.net/'
    config.base_path = 'api'
  	config.debugging = true

    client = OpenapiClient::AnalyzeApi.new
    client.api_client.config = config
    client
  end

  def time_from_meta(timestamp)
    timestamp.to_s.to_time
  rescue
    nil
  end

  def exifer
    @exifer ||= EXIFAnalyzer.new
  end

  def annotator
    @annotator ||= Annotator.new
  end
end
