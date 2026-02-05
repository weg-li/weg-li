# frozen_string_literal: true

class GeminiAnnotator
  include PhotoHelper
  include Rails.application.routes.url_helpers

  VEHICLE_COLORS = %w[black white silver gray beige blue brown yellow green red violet purple pink orange gold].freeze
  VEHICLE_TYPES = %w[car truck bike scooter van].freeze

  MODELS = {
    "2.0" => "gemini-2.0-flash",
    "2.5" => "gemini-2.5-flash",
    "3.0" => "gemini-3-flash-preview",
  }.freeze

  def annotate_object(key)
    uri = image_url(key)
    call_api(request_body_with_uri(uri))
  rescue StandardError => e
    Rails.logger.error("GeminiAnnotator error for key #{key}: #{e.message}")
    nil
  end

  def image_url(key)
    if Rails.env.development?
      gcloud = Google::Cloud.new
      storage = gcloud.storage
      bucket = storage.bucket(Annotator.bucket_name)
      file = bucket.file key
      file.signed_url
    else
      cloudflare_image_resize_url(key, :default, true)
    end
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
      Rails.logger.error("Gemini API error: #{response.status} #{response.body}")
      nil
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

      ## German License Plate Format

      Format: [DISTRICT] [LETTERS] [NUMBERS]
      - DISTRICT: 1-3 letters (city code like B, M, HH, KÜN)
      - LETTERS: 1-2 letters
      - NUMBERS: 1-4 digits
      - Optional E/H suffix for electric/historic

      Examples: "B AB 1234", "M XY 567", "HH A 1", "KÜN AB 12"

      IMPORTANT:
      - Only transcribe characters you can clearly read
      - Ignore TÜV/HU stickers (colored round seals) - they are NOT letters
      - If uncertain about any character, return null for the whole plate
      - Do NOT guess or hallucinate characters

      ## Task

      For each vehicle, extract:
      - registration: License plate text. Use SPACE between district, letters, and numbers. Set to null if not clearly readable.
      - brand: Manufacturer name (e.g. "Mercedes-Benz", "BMW", "Volkswagen"). Set to null if not identifiable.
      - color: Body color. Must be one of: #{VEHICLE_COLORS.join(', ')}. Set to null if not determinable.
      - vehicle_type: Must be one of: #{VEHICLE_TYPES.join(', ')}.
      - is_likely_subject: true if this vehicle is likely the main subject of the photo.
      - gps: the EXIF metadata.

      Return a JSON object with:
      - vehicles: Array of all vehicles, ordered by likelihood of being the main subject (most likely first).
      - scene_description: One sentence describing the scene.
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
              is_likely_subject: { type: "BOOLEAN" },
              gps: { type: "STRING", nullable: true },
            },
            required: %w[registration brand color vehicle_type is_likely_subject],
          },
        },
        scene_description: { type: "STRING" },
      },
      required: %w[vehicles scene_description],
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
    Rails.logger.error("Gemini response parse error: #{e.message} #{body}")
    nil
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
    raw = ENV.fetch("GEMINI_MODEL", "2.5")
    MODELS.fetch(raw, raw)
  end

  def api_key
    ENV.fetch("GEMINI_API_KEY")
  end
end
