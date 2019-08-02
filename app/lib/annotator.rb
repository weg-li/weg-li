require "google/cloud/vision"
require "google/cloud/storage"


class Annotator

  def self.grep_text(result)
    result[:text_annotations].flat_map { |match| match[:description].split("\n").map { |token| yield(token) } }.compact.uniq
  end

  COLORS = [
    Color::RGB::Beige,
    Color::RGB::Blue,
    Color::RGB::Brown,
    Color::RGB::Yellow,
    Color::RGB::Grey,
    Color::RGB::Green,
    Color::RGB::Red,
    Color::RGB::Black,
    Color::RGB::Silver,
    Color::RGB::Violet,
    Color::RGB::White,
    Color::RGB::Orange,
    Color::RGB::Gold,
  ]

  def self.dominant_colors(result)
    rgbs = result.dig(:image_properties_annotation, :dominant_colors, :colors).map { |color| Color::RGB.new(color[:color][:red], color[:color][:green], color[:color][:blue]) }
    rgbs.map { |rgb| rgb.closest_match(COLORS).name }
  end

  def initialize
    @bucket_name = "weg-li-#{Rails.env}"
  end

  def annotate_file(file_name = Rails.root.join('spec/support/assets/mercedes.jpg').to_s)
    image = { content: File.binread(file_name) }

    annotate(image)
  end

  def annotate_object(key = 'ydmE3qL1CT32rH6hunWtxCzx')
    image = { source: { gcs_image_uri: "gs://#{@bucket_name}/#{key}" } }

    annotate(image)
  end

  def annotate(image)
    request = [
      {
        image: image,
        features: [
          {type: 'LABEL_DETECTION'},
          {type: 'TEXT_DETECTION'},
          # {type: 'LANDMARK_DETECTION'},
          # {type: 'OBJECT_LOCALIZATION'},
          {type: 'IMAGE_PROPERTIES'},
        ],
      },
    ]
    response = vision_client.batch_annotate_images(request)
    response.responses.first.to_h
  end

  def download
    storage = Google::Cloud::Storage.new
    bucket = storage.bucket(@bucket_name)
    file = bucket.file "Screen Shot 2018-11-06 at 16.39.16.png"
    file.download "tmp/#{file.name}"
  end

  private

  def vision_client
    @vision_client ||= Google::Cloud::Vision::ImageAnnotator.new
  end
end
