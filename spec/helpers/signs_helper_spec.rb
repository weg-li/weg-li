# frozen_string_literal: true

require "spec_helper"

describe SignsHelper do
  context "signify" do
    it "adds style to show signs" do
      Fabricate.create(:sign, number: "000", description: "bla")
      Fabricate.create(:sign, number: "000.1", description: "bla")
      Fabricate.create(:sign, number: "000-1", description: "bla")
      Fabricate.create(:sign, number: "000.1-10", description: "bla")
      Fabricate.create(:sign, number: "456", description: "bla")

      expect(helper.signify(nil)).to eql(nil)
      expect(helper.signify("hi")).to eql("hi")
      expect(helper.signify("hi 000")).to eql("hi <a class=\"sign\" href=\"/signs/000\">000</a>")
      expect(helper.signify("hi 000.1")).to eql("hi <a class=\"sign\" href=\"/signs/000.1\">000.1</a>")
      expect(helper.signify("hi 000-1")).to eql("hi <a class=\"sign\" href=\"/signs/000-1\">000-1</a>")
      expect(helper.signify("hi 000.1-10")).to eql("hi <a class=\"sign\" href=\"/signs/000.1-10\">000.1-10</a>")
      expect(helper.signify("hi <000/456>")).to eql("hi &lt;<a class=\"sign\" href=\"/signs/000\">000</a>/<a class=\"sign\" href=\"/signs/456\">456</a>&gt;")
    end
  end
end
