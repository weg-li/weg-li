# frozen_string_literal: true

require "google/cloud/storage"

class GeminiAnnotator
  VEHICLE_COLORS = %w[black white silver gray beige blue brown yellow green red violet purple pink orange gold].freeze
  VEHICLE_TYPES = %w[car truck bike scooter van].freeze

  MODELS = {
    "2.0" => "gemini-2.0-flash",
    "2.5" => "gemini-2.5-flash",
    "3.0" => "gemini-3-flash-preview",
  }.freeze

  def annotate_object(key)
    image_bytes = download_bytes(key)
    return nil if image_bytes.blank?

    analyze_image(image_bytes)
  rescue StandardError => e
    Rails.logger.error("GeminiAnnotator error for key #{key}: #{e.message}")
    nil
  end

  def annotate_file(file_name = Rails.root.join("spec/fixtures/files/mercedes.jpg").to_s)
    image_bytes = File.binread(file_name)
    analyze_image(image_bytes)
  end

  def self.normalize_plate(plate)
    return plate if plate.blank?

    plate = plate.strip.upcase

    # Insert space between letters and digits where missing
    # "B JJ188E" → "B JJ 188E", "BJJ188" → "BJJ 188"
    plate = plate.gsub(/([A-ZÄÖÜ])(\d)/, '\1 \2')

    # Collapse multiple spaces
    plate.gsub(/\s+/, " ")
  end

  private

  def analyze_image(image_bytes, mime_type: "image/jpeg")
    encoded = Base64.strict_encode64(image_bytes)

    response = client.post(
      api_url,
      json: request_body(encoded, mime_type),
    )

    if response.status.success?
      parse_response(response)
    else
      Rails.logger.error("Gemini API error: #{response.status} #{response.body}")
      nil
    end
  end

  def request_body(encoded_image, mime_type)
    {
      contents: [{
        parts: [
          { text: prompt },
          { inline_data: { mime_type:, data: encoded_image } },
        ],
      }],
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: response_schema,
      },
    }
  end

  def prompt
    <<~PROMPT
      You are analyzing a photo taken by a citizen reporter documenting illegal parking in Germany.
      Your task is to identify all vehicles and determine which ones are committing parking violations.

      ## German Parking Law Context

      Common violations include:
      - Parking on sidewalks (Gehweg) without explicit permission signs
      - Parking on or blocking bike lanes (Radweg / Radschutzstreifen)
      - Parking on zigzag lines (Zickzacklinien / Grenzmarkierung) — painted zig-zag patterns on the road, often near pedestrian crossings or bus stops, where stopping and parking is strictly prohibited
      - Parking in no-parking zones (absolutes/eingeschränktes Haltverbot)
      - Parking on crosswalks (Zebrastreifen) or within 5m of them
      - Double parking (Zweite-Reihe-Parken)
      - Parking in fire lanes (Feuerwehrzufahrt)
      - Blocking lowered curbs (abgesenkter Bordstein)
      - Parking against the direction of traffic

      Look carefully at road markings, signs, curb paint, and the position of each vehicle relative to these features.

      ## Instructions

      For EACH vehicle visible in the image, extract:
      - registration: License plate in German format (e.g. "B AB 1234", "HH XY 567", "M AB 123E" for electric). Use SPACE between city prefix, letters, and numbers. Set to null if not readable.
      - brand: Manufacturer name (e.g. "Mercedes-Benz", "BMW", "Volkswagen"). Set to null if not identifiable.
      - color: Body color. Must be one of: #{VEHICLE_COLORS.join(', ')}. Set to null if not determinable.
      - vehicle_type: Must be one of: #{VEHICLE_TYPES.join(', ')}.
      - location_in_image: Where the vehicle appears (e.g. "center", "left foreground").
      - is_likely_subject: true if the photographer likely intended to document this vehicle as violating parking rules. Consider camera focus, centering, proximity, and angle.
      - violation_visible: true if this vehicle appears to be parked illegally based on visual evidence.
      - violation_hint: Brief description of the violation if visible (e.g. "parked on zigzag line", "blocking bike lane"). Null if no violation apparent.

      Return a JSON object with:
      - vehicles: Array of all vehicles, ordered by likelihood of being the violation subject (most likely first).
      - scene_description: One sentence describing the scene and visible road markings.
      - multiple_violations: true if more than one vehicle appears to be violating parking rules.
    PROMPT
  end

  def response_schema
    {
      type: "OBJECT",
      properties: {
        vehicles: {
          type: "ARRAY",
          items: {
            type: "OBJECT",
            properties: {
              registration: { type: "STRING", nullable: true },
              brand: { type: "STRING", nullable: true },
              color: { type: "STRING", nullable: true, enum: VEHICLE_COLORS },
              vehicle_type: { type: "STRING", nullable: true, enum: VEHICLE_TYPES },
              location_in_image: { type: "STRING" },
              is_likely_subject: { type: "BOOLEAN" },
              violation_visible: { type: "BOOLEAN" },
              violation_hint: { type: "STRING", nullable: true },
            },
            required: %w[registration brand color vehicle_type location_in_image is_likely_subject violation_visible],
          },
        },
        scene_description: { type: "STRING" },
        multiple_violations: { type: "BOOLEAN" },
      },
      required: %w[vehicles scene_description multiple_violations],
    }
  end

  def parse_response(response)
    body = JSON.parse(response.body.to_s)
    text = body.dig("candidates", 0, "content", "parts", 0, "text")
    return nil if text.blank?

    result = JSON.parse(text)
    result["model_version"] = model

    # Normalize plate formatting
    Array(result["vehicles"]).each do |vehicle|
      vehicle["registration"] = self.class.normalize_plate(vehicle["registration"])
    end

    result
  rescue JSON::ParserError => e
    Rails.logger.error("Gemini response parse error: #{e.message}")
    nil
  end

  def download_bytes(key)
    storage = Google::Cloud::Storage.new
    bucket = storage.bucket(Annotator.bucket_name)
    file = bucket.file(key)
    return nil if file.nil?

    io = StringIO.new
    io.set_encoding("BINARY")
    file.download(io)
    io.rewind
    io.read
  end

  def client
    @client ||= HTTP.use(logging: { logger: Rails.logger }).timeout(30)
  end

  def api_url
    "#{endpoint}/v1beta/models/#{model}:generateContent?key=#{api_key}"
  end

  def endpoint
    "https://generativelanguage.googleapis.com"
  end

  def model
    raw = ENV.fetch("GEMINI_MODEL", "3.0")
    MODELS.fetch(raw, raw)
  end

  def api_key
    ENV.fetch("GEMINI_API_KEY")
  end
end
