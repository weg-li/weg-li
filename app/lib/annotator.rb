require "google/cloud/vision"
require "google/cloud/storage"

class Annotator
  def self.unsafe?(result)
    (result[:safe_search_annotation] || {}).any? { |_, value| [:LIKELY, :VERY_LIKELY].include?(value) }
  end

  def self.grep_text(result)
    result[:text_annotations].flat_map { |entry| entry[:description].split("\n").map { |token| yield(token) } }.compact.uniq
  end

  def self.grep_label(result)
    result[:label_annotations].flat_map { |entry| entry[:description].split("\n").map { |token| yield(token) } }.compact.uniq
  end

  COLORS = {
    Color::RGB::AliceBlue => Color::RGB::White,
    Color::RGB::AntiqueWhite => Color::RGB::Beige,
    Color::RGB::Aqua => Color::RGB::Blue,
    Color::RGB::Aquamarine => Color::RGB::Green,
    Color::RGB::Azure => Color::RGB::White,
    Color::RGB::Beige => Color::RGB::Beige,
    Color::RGB::Bisque => Color::RGB::Beige,
    Color::RGB::RebeccaPurple => Color::RGB::Purple,
    Color::RGB::Black => Color::RGB::Black,
    Color::RGB::BlanchedAlmond => Color::RGB::Beige,
    Color::RGB::Blue => Color::RGB::Blue,
    Color::RGB::BlueViolet => Color::RGB::Violet,
    Color::RGB::Brown => Color::RGB::Brown,
    Color::RGB::BurlyWood => Color::RGB::Beige,
    Color::RGB::CadetBlue => Color::RGB::Blue,
    Color::RGB::Carnation => Color::RGB::Violet,
    Color::RGB::Cayenne => Color::RGB::Red,
    Color::RGB::Chartreuse => Color::RGB::Green,
    Color::RGB::Chocolate => Color::RGB::Brown,
    Color::RGB::Coral => Color::RGB::Red,
    Color::RGB::CornflowerBlue => Color::RGB::Blue,
    Color::RGB::Cornsilk => Color::RGB::White,
    Color::RGB::Crimson => Color::RGB::Red,
    Color::RGB::Cyan => Color::RGB::Blue,
    Color::RGB::DarkBlue => Color::RGB::Blue,
    Color::RGB::DarkCyan => Color::RGB::Blue,
    Color::RGB::DarkGoldenRod => Color::RGB::Gold,
    Color::RGB::DarkGreen => Color::RGB::Green,
    Color::RGB::DarkKhaki => Color::RGB::Beige,
    Color::RGB::DarkMagenta => Color::RGB::Purple,
    Color::RGB::DarkOliveGreen => Color::RGB::Green,
    Color::RGB::DarkOrange => Color::RGB::Orange,
    Color::RGB::DarkOrchid => Color::RGB::Purple,
    Color::RGB::DarkRed => Color::RGB::Red,
    Color::RGB::DarkSalmon => Color::RGB::Red,
    Color::RGB::DarkSeaGreen => Color::RGB::Green,
    Color::RGB::DarkSlateBlue => Color::RGB::Blue,
    Color::RGB::DarkTurquoise => Color::RGB::Blue,
    Color::RGB::DarkViolet => Color::RGB::Violet,
    Color::RGB::Darkorange => Color::RGB::Orange,
    Color::RGB::DeepPink => Color::RGB::Pink,
    Color::RGB::DeepSkyBlue => Color::RGB::Blue,
    Color::RGB::DodgerBlue => Color::RGB::Blue,
    Color::RGB::Feldspar => Color::RGB::Brown,
    Color::RGB::FireBrick => Color::RGB::Brown,
    Color::RGB::FloralWhite => Color::RGB::White,
    Color::RGB::ForestGreen => Color::RGB::Green,
    Color::RGB::Fuchsia => Color::RGB::Violet,
    Color::RGB::Gainsboro => Color::RGB::White,
    Color::RGB::GhostWhite => Color::RGB::White,
    Color::RGB::Gold => Color::RGB::Gold,
    Color::RGB::GoldenRod => Color::RGB::Gold,
    Color::RGB::Gray => Color::RGB::Gray,
    Color::RGB::Green => Color::RGB::Green,
    Color::RGB::GreenYellow => Color::RGB::Green,
    Color::RGB::HoneyDew => Color::RGB::White,
    Color::RGB::HotPink => Color::RGB::Pink,
    Color::RGB::IndianRed => Color::RGB::Red,
    Color::RGB::Indigo => Color::RGB::Purple,
    Color::RGB::Ivory => Color::RGB::White,
    Color::RGB::Khaki => Color::RGB::Beige,
    Color::RGB::Lavender => Color::RGB::Violet,
    Color::RGB::LavenderBlush => Color::RGB::White,
    Color::RGB::LawnGreen => Color::RGB::Green,
    Color::RGB::LemonChiffon => Color::RGB::Yellow,
    Color::RGB::LightBlue => Color::RGB::Blue,
    Color::RGB::LightCoral => Color::RGB::Red,
    Color::RGB::LightCyan => Color::RGB::Blue,
    Color::RGB::LightGoldenRodYellow => Color::RGB::Gold,
    Color::RGB::LightGreen => Color::RGB::Green,
    Color::RGB::LightPink => Color::RGB::Pink,
    Color::RGB::LightSalmon => Color::RGB::Red,
    Color::RGB::LightSeaGreen => Color::RGB::Green,
    Color::RGB::LightSkyBlue => Color::RGB::Blue,
    Color::RGB::LightSlateBlue => Color::RGB::Blue,
    Color::RGB::LightSteelBlue => Color::RGB::Blue,
    Color::RGB::LightYellow => Color::RGB::Yellow,
    Color::RGB::Lime => Color::RGB::Green,
    Color::RGB::LimeGreen => Color::RGB::Green,
    Color::RGB::Linen => Color::RGB::White,
    Color::RGB::Magenta => Color::RGB::Violet,
    Color::RGB::Maroon => Color::RGB::Red,
    Color::RGB::MediumAquaMarine => Color::RGB::Green,
    Color::RGB::MediumBlue => Color::RGB::Blue,
    Color::RGB::MediumOrchid => Color::RGB::Violet,
    Color::RGB::MediumPurple => Color::RGB::Purple,
    Color::RGB::MediumSeaGreen => Color::RGB::Green,
    Color::RGB::MediumSlateBlue => Color::RGB::Blue,
    Color::RGB::MediumSpringGreen => Color::RGB::Green,
    Color::RGB::MediumTurquoise => Color::RGB::Blue,
    Color::RGB::MediumVioletRed => Color::RGB::Violet,
    Color::RGB::MidnightBlue => Color::RGB::Blue,
    Color::RGB::MintCream => Color::RGB::White,
    Color::RGB::MistyRose => Color::RGB::Beige,
    Color::RGB::Moccasin => Color::RGB::Beige,
    Color::RGB::NavajoWhite => Color::RGB::Beige,
    Color::RGB::Navy => Color::RGB::Blue,
    Color::RGB::OldLace => Color::RGB::Beige,
    Color::RGB::Olive => Color::RGB::Green,
    Color::RGB::OliveDrab => Color::RGB::Green,
    Color::RGB::Orange => Color::RGB::Orange,
    Color::RGB::OrangeRed => Color::RGB::Red,
    Color::RGB::Orchid => Color::RGB::Violet,
    Color::RGB::PaleGoldenRod => Color::RGB::Gold,
    Color::RGB::PaleGreen => Color::RGB::Green,
    Color::RGB::PaleTurquoise => Color::RGB::Blue,
    Color::RGB::PaleVioletRed => Color::RGB::Violet,
    Color::RGB::PapayaWhip => Color::RGB::Beige,
    Color::RGB::PeachPuff => Color::RGB::Beige,
    Color::RGB::Peru => Color::RGB::Brown,
    Color::RGB::Pink => Color::RGB::Pink,
    Color::RGB::Plum => Color::RGB::Violet,
    Color::RGB::PowderBlue => Color::RGB::Blue,
    Color::RGB::Purple => Color::RGB::Purple,
    Color::RGB::Red => Color::RGB::Red,
    Color::RGB::RosyBrown => Color::RGB::Brown,
    Color::RGB::RoyalBlue => Color::RGB::Blue,
    Color::RGB::SaddleBrown => Color::RGB::Brown,
    Color::RGB::Salmon => Color::RGB::Red,
    Color::RGB::SandyBrown => Color::RGB::Brown,
    Color::RGB::SeaGreen => Color::RGB::Green,
    Color::RGB::SeaShell => Color::RGB::White,
    Color::RGB::Sienna => Color::RGB::Brown,
    Color::RGB::Silver => Color::RGB::Silver,
    Color::RGB::SkyBlue => Color::RGB::Blue,
    Color::RGB::SlateBlue => Color::RGB::Blue,
    Color::RGB::Snow => Color::RGB::White,
    Color::RGB::SpringGreen => Color::RGB::Green,
    Color::RGB::SteelBlue => Color::RGB::Blue,
    Color::RGB::Tan => Color::RGB::Beige,
    Color::RGB::Teal => Color::RGB::Green,
    Color::RGB::Thistle => Color::RGB::Violet,
    Color::RGB::Tomato => Color::RGB::Red,
    Color::RGB::Turquoise => Color::RGB::Green,
    Color::RGB::Violet => Color::RGB::Violet,
    Color::RGB::VioletRed => Color::RGB::Violet,
    Color::RGB::Wheat => Color::RGB::Beige,
    Color::RGB::White => Color::RGB::White,
    Color::RGB::WhiteSmoke => Color::RGB::White,
    Color::RGB::Yellow => Color::RGB::Yellow,
    Color::RGB::YellowGreen => Color::RGB::Green,
  }

  TOTALS = {
    Color::RGB::Gray10 => Color::RGB::Gray,
    Color::RGB::Gray20 => Color::RGB::Gray,
    Color::RGB::Gray30 => Color::RGB::Gray,
    Color::RGB::Gray40 => Color::RGB::Gray,
    Color::RGB::Gray50 => Color::RGB::Gray,
    Color::RGB::Gray60 => Color::RGB::Gray,
    Color::RGB::Gray70 => Color::RGB::Gray,
    Color::RGB::Gray80 => Color::RGB::Gray,
    Color::RGB::Gray90 => Color::RGB::Gray,
  }.merge(COLORS)

  def self.dominant_colors(result)
    colors = result.dig(:image_properties_annotation, :dominant_colors, :colors)
    return [] if colors.blank?

    colors.map do |color|
      rgb = Color::RGB.new(color[:color][:red], color[:color][:green], color[:color][:blue])
      closest = rgb.closest_match(COLORS.keys, 20) || rgb.closest_match(TOTALS.keys)
      name = Annotator::TOTALS[closest].name
      [name, (color[:score].to_f + color[:pixel_fraction].to_f).fdiv(2)]
    end
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
        image_context: { language_hints: ['de'] },
        features: [
          {type: 'LABEL_DETECTION'},
          {type: 'DOCUMENT_TEXT_DETECTION'},
          {type: 'LOGO_DETECTION'},
          {type: 'IMAGE_PROPERTIES'},
          {type: 'SAFE_SEARCH_DETECTION'},
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
