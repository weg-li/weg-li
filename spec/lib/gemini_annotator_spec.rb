# frozen_string_literal: true

require "spec_helper"

describe GeminiAnnotator do
  let(:api_key) { "test-gemini-api-key" }
  let(:model) { "gemini-2.0-flash" }
  let(:api_url) { "https://generativelanguage.googleapis.com/v1beta/models/#{model}:generateContent?key=#{api_key}" }

  before do
    ENV["GEMINI_API_KEY"] = api_key
    ENV["GEMINI_MODEL"] = "2.0"
  end

  after do
    ENV.delete("GEMINI_API_KEY")
    ENV.delete("GEMINI_MODEL")
  end

  describe ".normalize_plate" do
    it "inserts space between letters and digits" do
      expect(described_class.normalize_plate("B JJ188E")).to eql("B JJ 188E")
    end

    it "preserves correctly spaced plates" do
      expect(described_class.normalize_plate("B AB 1234")).to eql("B AB 1234")
    end

    it "handles umlauts" do
      expect(described_class.normalize_plate("KÜN X 2002")).to eql("KÜN X 2002")
    end

    it "collapses multiple spaces" do
      expect(described_class.normalize_plate("B  AB  1234")).to eql("B AB 1234")
    end

    it "returns nil for blank input" do
      expect(described_class.normalize_plate(nil)).to be_nil
      expect(described_class.normalize_plate("")).to eql("")
    end
  end

  describe "#annotate_file" do
    let(:gemini_response) do
      {
        candidates: [{
          content: {
            parts: [{
              text: {
                vehicles: [
                  {
                    registration: "HH AB 1234",
                    brand: "Mercedes-Benz",
                    color: "silver",
                    vehicle_type: "car",
                    location_in_image: "center",
                    is_likely_subject: true,
                    violation_visible: true,
                    violation_hint: "parked on sidewalk",
                  },
                  {
                    registration: "B XY 567",
                    brand: "BMW",
                    color: "black",
                    vehicle_type: "car",
                    location_in_image: "left background",
                    is_likely_subject: false,
                    violation_visible: false,
                    violation_hint: nil,
                  },
                ],
                scene_description: "Two cars parked on a residential street.",
                multiple_violations: false,
              }.to_json,
            }],
          },
        }],
      }
    end

    it "returns multi-vehicle structured data" do
      stub_request(:post, api_url)
        .to_return(
          status: 200,
          body: gemini_response.to_json,
          headers: { "Content-Type" => "application/json" },
        )

      result = subject.annotate_file

      expect(result["vehicles"].length).to eql(2)
      expect(result["vehicles"].first).to include(
        "registration" => "HH AB 1234",
        "brand" => "Mercedes-Benz",
        "color" => "silver",
        "is_likely_subject" => true,
      )
      expect(result["scene_description"]).to be_present
      expect(result["multiple_violations"]).to eql(false)
      expect(result["model_version"]).to eql(model)
    end

    it "normalizes plates in response" do
      response_with_bad_plate = {
        candidates: [{
          content: {
            parts: [{
              text: {
                vehicles: [{
                  registration: "B JJ188E",
                  brand: "Porsche",
                  color: "gray",
                  vehicle_type: "car",
                  location_in_image: "center",
                  is_likely_subject: true,
                  violation_visible: false,
                  violation_hint: nil,
                }],
                scene_description: "A car parked on a street.",
                multiple_violations: false,
              }.to_json,
            }],
          },
        }],
      }

      stub_request(:post, api_url)
        .to_return(
          status: 200,
          body: response_with_bad_plate.to_json,
          headers: { "Content-Type" => "application/json" },
        )

      result = subject.annotate_file

      expect(result["vehicles"].first["registration"]).to eql("B JJ 188E")
    end

    it "returns nil on API error" do
      stub_request(:post, api_url)
        .to_return(status: 500, body: "Internal Server Error")

      expect(subject.annotate_file).to be_nil
    end

    it "returns nil on malformed JSON response" do
      bad_response = {
        candidates: [{
          content: {
            parts: [{ text: "not valid json {{{" }],
          },
        }],
      }

      stub_request(:post, api_url)
        .to_return(
          status: 200,
          body: bad_response.to_json,
          headers: { "Content-Type" => "application/json" },
        )

      expect(subject.annotate_file).to be_nil
    end

    it "sends image as base64 inline data" do
      stub_request(:post, api_url)
        .to_return(
          status: 200,
          body: gemini_response.to_json,
          headers: { "Content-Type" => "application/json" },
        )

      subject.annotate_file

      expect(WebMock).to(have_requested(:post, api_url).with do |req|
        body = JSON.parse(req.body)
        parts = body.dig("contents", 0, "parts")
        parts.any? { |p| p.dig("inline_data", "mime_type") == "image/jpeg" } &&
          parts.any? { |p| p.dig("inline_data", "data").present? }
      end)
    end
  end

  describe "model resolution" do
    after { ENV.delete("GEMINI_MODEL") }

    it "resolves short names to full model IDs" do
      { "2.0" => "gemini-2.0-flash", "2.5" => "gemini-2.5-flash", "3.0" => "gemini-3-flash-preview" }.each do |short, full|
        ENV["GEMINI_MODEL"] = short
        annotator = described_class.new

        stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/#{full}:generateContent?key=#{api_key}")
          .to_return(status: 200, body: { candidates: [{ content: { parts: [{ text: { vehicles: [], scene_description: "", multiple_violations: false }.to_json }] } }] }.to_json)

        annotator.annotate_file
        expect(WebMock).to have_requested(:post, /#{full}/)
      end
    end

    it "passes through full model IDs" do
      ENV["GEMINI_MODEL"] = "gemini-3-flash-preview"

      stub_request(:post, /gemini-3-flash-preview/)
        .to_return(status: 200, body: { candidates: [{ content: { parts: [{ text: { vehicles: [], scene_description: "", multiple_violations: false }.to_json }] } }] }.to_json)

      subject.annotate_file
      expect(WebMock).to have_requested(:post, /gemini-3-flash-preview/)
    end

    it "defaults to 3.0" do
      ENV.delete("GEMINI_MODEL")

      stub_request(:post, /gemini-3-flash-preview/)
        .to_return(status: 200, body: { candidates: [{ content: { parts: [{ text: { vehicles: [], scene_description: "", multiple_violations: false }.to_json }] } }] }.to_json)

      subject.annotate_file
      expect(WebMock).to have_requested(:post, /gemini-3-flash-preview/)
    end
  end
end
