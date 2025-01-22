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
    let(:sign) { Fabricate.build(:sign, number: "270.1-40", description: "nice brudi") }

    it "has an image" do
      expect(sign.image).to eql("signs/270.1-40.jpg.png")
    end

    it "has an url" do
      expect(sign.url).to eql("https://example.com/signs/270.1-40-nice-brudi.png")
    end
  end

  context "grouping" do
    it "handles the grouping" do
      group = Fabricate.create(:sign, number: "1000", description: "bla")
      sub = Fabricate.create(:sign, number: "1000-10", description: "bla")

      expect(group.grouped?).to be_falsy
      expect(group.category?).to be_truthy
      expect(group.parent).to be_nil
      expect(group.parent_number).to be_nil

      expect(sub.grouped?).to be_truthy
      expect(sub.category?).to be_falsy
      expect(sub.parent_number).to eql("1000")
      expect(sub.parent).to eql(group)
    end
  end

  context "acts_as_api" do
    let(:sign) { Fabricate.build(:sign, number: "999-1", description: "bla") }
    it "generates proper results" do
      expect(sign.as_api_response(:public_beta)).to eql(
        {
          description: "bla",
          number: "999-1",
          url: "https://example.com/signs/999-1-bla.png",
          updated_at: nil,
          created_at: nil,
        },
      )
    end
  end
end
