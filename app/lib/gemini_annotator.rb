# frozen_string_literal: true

class GeminiAnnotator
  VEHICLE_COLORS = %w[black white silver gray beige blue brown yellow green red violet purple pink orange gold].freeze
  VEHICLE_TYPES = %w[car truck bike scooter van].freeze

  MODELS = {
    "2.0" => "gemini-2.0-flash",
    "2.5" => "gemini-2.5-flash",
    "3.0" => "gemini-3-flash-preview",
  }.freeze

  def annotate_object(key)
    gcs_uri = "gs://#{Annotator.bucket_name}/#{key}"
    call_api(request_body_with_uri(gcs_uri))
  rescue StandardError => e
    Rails.logger.error("GeminiAnnotator error for key #{key}: #{e.message}")
    nil
  end

  def annotate_file(file_name = Rails.root.join("spec/fixtures/files/mercedes.jpg").to_s)
    image_bytes = File.binread(file_name)
    encoded = Base64.strict_encode64(image_bytes)
    call_api(request_body_with_inline_data(encoded))
  end

  private

  def call_api(body)
    response = client.post(api_url, json: body)

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
          { text: prompt },
          { file_data: { mime_type:, file_uri: gcs_uri } },
        ],
      }],
      generationConfig: generation_config,
    }
  end

  def request_body_with_inline_data(encoded_image, mime_type: "image/jpeg")
    {
      contents: [{
        parts: [
          { text: prompt },
          { inline_data: { mime_type:, data: encoded_image } },
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
      You are analyzing a photo of parked vehicles taken by a citizen reporter in Germany.

      ## Instructions

      For EACH vehicle visible in the image, extract:
      - registration: License plate in German format. Use SPACE between city prefix, letters, and numbers. Set to null if not readable.
      - brand: Manufacturer name (e.g. "Mercedes-Benz", "BMW", "Volkswagen"). Set to null if not identifiable.
      - color: Body color. Must be one of: #{VEHICLE_COLORS.join(', ')}. Set to null if not determinable.
      - vehicle_type: Must be one of: #{VEHICLE_TYPES.join(', ')}.
      - location_in_image: Where the vehicle appears (e.g. "center", "left foreground").
      - bounding_box: [ymin, xmin, ymax, xmax] normalized to a 0–1000 scale, tightly enclosing the entire vehicle.
      - plate_bounding_box: [ymin, xmin, ymax, xmax] normalized to a 0–1000 scale, tightly enclosing the license plate. Null if not visible.
      - is_likely_subject: true if this vehicle is likely the main subject of the photo (consider focus, centering).

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
              location_in_image: { type: "STRING" },
              bounding_box: {
                type: "ARRAY",
                items: { type: "INTEGER" },
                description: "Vehicle bounding box as [ymin, xmin, ymax, xmax] normalized to 0-1000",
              },
              plate_bounding_box: {
                type: "ARRAY",
                nullable: true,
                items: { type: "INTEGER" },
                description: "License plate bounding box as [ymin, xmin, ymax, xmax] normalized to 0-1000",
              },
              is_likely_subject: { type: "BOOLEAN" },
            },
            required: %w[registration brand color vehicle_type location_in_image bounding_box is_likely_subject],
          },
        },
        scene_description: { type: "STRING" },
      },
      required: %w[vehicles scene_description],
    }
  end

  def parse_response(response)
    body = JSON.parse(response.body.to_s)
    text = body.dig("candidates", 0, "content", "parts", 0, "text")
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
    Rails.logger.error("Gemini response parse error: #{e.message}")
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
