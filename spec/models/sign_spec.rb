# frozen_string_literal: true

require "rails_helper"

describe Sign do
  let(:sign) { Fabricate.build(:sign) }

  context "validation" do
    it "is valid" do
      expect(sign).to be_valid
    end
  end

  context "referencing the image" do
    let(:sign) { Fabricate.build(:sign, number: "999-1") }

    it "has an image" do
      expect(sign.image).to eql("signs/999-1.jpg.png")
    end

    it "has an url" do
      expect(sign.url).to eql("https://example.com/signs/999-1.png")
    end
  end

  context "acts_as_api" do
    let(:sign) { Fabricate.build(:sign, number: "999-1", description: "bla") }
    it "generates proper results" do
      expect(sign.as_api_response(:public_beta)).to eql(
        {
          description: "bla",
          number: "999-1",
          url: "https://example.com/signs/999-1.png",
          updated_at: nil,
          created_at: nil,
        },
      )
    end
  end
end
