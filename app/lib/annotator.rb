require "google/cloud/vision"
require "google/cloud/storage"

class Annotator
  def self.unsafe?(result)
    (result[:safe_search_annotation] || {}).any? { |key, value| [:adult, :medical, :violence, :racy].include?(key) && [:LIKELY, :VERY_LIKELY].include?(value) }
  end

  def self.grep_text(result)
    result[:text_annotations].flat_map { |entry| entry[:description].split("\n").map { |token| yield(token) } }.compact.uniq
  end

  def self.grep_label(result)
    result[:label_annotations].flat_map { |entry| entry[:description].split("\n").map { |token| yield(token) } }.compact.uniq
  end

  def self.grep_logo(result)
    result[:logo_annotations].flat_map { |entry| entry[:description].split("\n").map { |token| yield(token) } }.compact.uniq
  end

  def self.dominant_colors(result, threshold: 0.1)
    colors = result.dig(:image_properties_annotation, :dominant_colors, :colors)
    return [] if colors.blank?

    colors = colors.select { |color| color[:score] >= threshold}
    colors.map do |color|
      name = Colorizor.closest_match(color[:color])
      [name, (color[:score].to_f + color[:pixel_fraction].to_f).fdiv(2)]
    end
  end

  def self.bucket_uri(key)
    "gs://#{bucket_name}/#{key}"
  end

  def self.bucket_name
    "weg-li-#{Rails.env}"
  end

  def annotate_file(file_name = Rails.root.join('spec/support/assets/mercedes.jpg').to_s)
    image = { content: File.binread(file_name) }

    annotate(image)
  end

  def annotate_yolo(key = 'ydmE3qL1CT32rH6hunWtxCzx')
    client = HTTP.use(logging: {logger: Rails.logger}).timeout(10)
    headers = { 'Content-Type' => 'application/json' }
    url = ENV.fetch('CAR_ML_URL', 'https://weg-li-car-ml.onrender.com')
    response = client.post(url, headers: headers, json: { google_cloud_urls: [key] })

    if response.status.success?
      JSON.parse(response.body)
    else
      raise HTTP::ResponseError.new(response.body)
    end
  end

  def annotate_object(key = 'ydmE3qL1CT32rH6hunWtxCzx')
    uri = self.class.bucket_uri(key)
    image = { source: { gcs_image_uri: uri } }

    annotate(image)
  end

  def annotate(image)
    request = {
      requests: [
        {
          image: image,
          image_context: { language_hints: ['de'] },
          features: [
            {type: 'DOCUMENT_TEXT_DETECTION'},
            {type: 'IMAGE_PROPERTIES'},
            # {type: 'SAFE_SEARCH_DETECTION'},
          ],
        },
      ]
    }
    response = image_annotator.batch_annotate_images(request)
    response.responses.first.to_h
  end

  def download(key = "Screen Shot 2018-11-06 at 16.39.16.png")
    storage = Google::Cloud::Storage.new
    bucket = storage.bucket(self.class.bucket_name)
    file = bucket.file(key)
    file.download "tmp/#{file.name}"
  end

  private

  def image_annotator
    @image_annotator ||= Google::Cloud::Vision.image_annotator do |config|
      # only for DOCUMENT_TEXT_DETECTION https://cloud.google.com/vision/docs/ocr#regionalization
      # config.endpoint = "eu-vision.googleapis.com"
    end
  end
end
