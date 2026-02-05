# frozen_string_literal: true

require "spec_helper"

describe ApplicationHelper do
  context "title" do
    it "creates a proper title" do
      helper.set_title("specific", "unspecific")
      expect(helper.title("least specific")).to eql("specific · unspecific · least specific")
    end
  end

  context "options_for_email" do
    it "selects the correct email for Munich district based on point" do
      district = Fabricate.create(:district, config: :munich, aliases: ["pp-mue.muenchen.pi11@polizei.bayern.de"])
      notice = Fabricate.build(:notice, street: "Marienplatz 1", zip: "80331", city: "München", latitude: 48.137154, longitude: 11.576124)

      options = helper.options_for_email(district, notice)
      expect(options).to include('<option selected="selected" value="pp-mue.muenchen.pi11@polizei.bayern.de">')
    end
    it "selects the correct email for Ploen district based on street" do
      district = Fabricate.create(:district, config: :ploen, email: "ordnungsamt@ploen.de", aliases: ["bussgeldstelle@kreis-ploen.de"])
      notice = Fabricate.build(:notice, street: "Appelwarder 1", zip: "24306", city: "Plön")

      options = helper.options_for_email(district, notice)
      expect(options).to include('<option selected="selected" value="ordnungsamt@ploen.de">')

      notice.street = "Andere Straße 5"
      options = helper.options_for_email(district, notice)
      expect(options).to include('<option selected="selected" value="bussgeldstelle@kreis-ploen.de">')
    end
  end
end
