# frozen_string_literal: true

class GeminiAnnotator
  attr_accessor :model

  def initialize(model: nil)
    @model = model || ENV.fetch("GEMINI_MODEL", "gemini-2.5-flash-lite")
  end

  def annotate_object(uri)
    call_api(request_body_with_uri(uri))
  end

  def annotate_file(file_name = Rails.root.join("spec/fixtures/files/mercedes.jpg").to_s)
    image_bytes = File.binread(file_name)
    encoded = Base64.strict_encode64(image_bytes)
    call_api(request_body_with_inline_data(encoded))
  end

  private

  def call_api(json)
    response = client.post(api_url, json: json)

    if response.status.success?
      parse_response(response)
    else
      raise HTTP::ResponseError.new, "Request failed with status #{response.status}: #{response.body}"
    end
  end

  def request_body_with_uri(gcs_uri, mime_type: "image/jpeg")
    {
      contents: [{
        parts: [
          { file_data: { mime_type:, file_uri: gcs_uri } },
          { text: prompt },
        ],
      }],
      generationConfig: generation_config,
    }
  end

  def request_body_with_inline_data(encoded_image, mime_type: "image/jpeg")
    {
      contents: [{
        parts: [
          { inline_data: { mime_type:, data: encoded_image } },
          { text: prompt },
        ],
      }],
      generationConfig: generation_config,
    }
  end

  def generation_config
    {
      responseMimeType: "application/json",
      responseSchema: response_schema,
    }
  end

  def prompt
    <<~PROMPT
      You are a license plate OCR specialist analyzing a photo from Germany.

      IMPORTANT:
      - Only transcribe characters you can clearly read
      - Ignore TÜV/HU stickers (colored round seals) - they are NOT letters
      - If uncertain about any character, return null for the whole plate
      - Do NOT guess or hallucinate characters

      ## German License Plate Format for KFZ (cars, trucks, bikes, vans, buses, trailers)

      Format: [DISTRICT] [LETTERS] [NUMBERS]
      - DISTRICT: 1-3 letters (city code like B, M, HH, KÜN)
      - LETTERS: 1-2 letters
      - NUMBERS: 1-4 digits
      - Optional E/H suffix for electric/historic

      Examples: "B AB 1234", "M XY 567", "HH A 1", "KÜN AB 12"

      ## German License Plate Format for Versicherungskennzeichen (mopeds, e-scooters, e-bikes)

      Format: 3[LETTERS] 3[NUMBERS]

      Examples: "780 HGA", "498 ABC"

      ## Foreign License Plate Format for KFZ

      Examples: Polish "SK 4C 001", Italian "MI AB 12345", French "AB-123-CD"

      ## Task

      For each vehicle, extract:
      - registration: License plate text. Use SPACE between district, letters, and numbers. Set to null if not clearly readable.
      - brand: Manufacturer name (e.g. "Mercedes-Benz", "BMW", "Volkswagen"). Set to null if not identifiable.
      - color: Body color. Must be one of: #{Vehicle.colors.join(', ')}. Set to null if not determinable.
      - vehicle_type: Must be one of: #{Brand.kinds.keys.join(', ')}.
      - is_likely_subject: true if this vehicle is likely the main subject of the photo.
      - country_code: the country code if it's a foreign plate (e.g. "D" for Germany, "F" for France), null if it's a German plate or not identifiable.

      Return a JSON object with:
      - vehicles: Array of all vehicles, ordered by likelihood of being the main subject (most likely first).
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
              color: { type: "STRING", nullable: true, enum: Vehicle.colors },
              vehicle_type: { type: "STRING", nullable: true, enum: Brand.kinds.keys },
              is_likely_subject: { type: "BOOLEAN" },
              country_code: { type: "STRING", nullable: true },
            },
            required: %w[registration brand color vehicle_type is_likely_subject country_code],
          },
        },
      },
      required: %w[vehicles],
    }
  end

  def parse_response(response)
    body = response.body.to_s
    data = JSON.parse(body)
    text = data.dig("candidates", 0, "content", "parts", 0, "text")
    return nil if text.blank?

    result = JSON.parse(text)
    result["model_version"] = model

    # Normalize plates via Vehicle.plate? (handles OCR errors, district disambiguation)
    Array(result["vehicles"]).each do |vehicle|
      next if vehicle["registration"].blank?

      matched = Vehicle.plate?(vehicle["registration"])
      vehicle["registration"] = matched.first if matched
    end

    result
  rescue JSON::ParserError => e
    raise HTTP::ResponseError.new, "Response malformed: #{e.message} (#{response.body})"
  end

  def client
    @client ||= HTTP.use(logging: { logger: Rails.logger }).timeout(timeout)
  end

  def api_url
    "#{endpoint}/v1beta/models/#{model}:generateContent?key=#{api_key}"
  end

  def endpoint
    "https://generativelanguage.googleapis.com"
  end

  def api_key
    ENV.fetch("GEMINI_API_KEY")
  end

  def timeout
    ENV.fetch("GEMINI_TIMEOUT_SECONDS", "20").to_i
  end
end
