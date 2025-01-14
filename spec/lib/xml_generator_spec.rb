# frozen_string_literal: true

require "spec_helper"

describe XmlGenerator do
  let(:winowig) { File.read(file_fixture("winowig.xml")) }
  let(:owi21) { File.read(file_fixture("owi21.xml")) }

  it "handles the xml generation for owi21" do
    travel_to("20.01.2020 15:00:00 UTC".to_time.utc) do
      district = Fabricate(:district, zip: "12345")
      user = Fabricate.build(:user, name: "Uschi Müller", email: "test@example.com", city: "Dorf", zip: "54321", street: "Am Weiher 123", appendix: "2. OG", phone: "0178123456", date_of_birth: "31.12.2000")
      charge = Fabricate.build(:charge, tbnr: "142170", description: "Parken auf einem unbeschilderten Radweg")
      notice = Fabricate.build(:notice, user:, charge:, brand: "märzer", color: "black", registration: "HH AB 123", city: "Dorf", street: "Am Weiher 123", zip: "12345", district:, token: "xxxxxxx")
      notice.save!
      notice.photos.first.update!(key: "test.jpg")

      result = XmlGenerator.new.generate(notice, :owi21)

      # file_fixture("owi21.xml").write(result)
      expect(owi21).to eql(result)
    end
  end

  it "handles the xml generation for winowig" do
    travel_to("20.01.2020 15:00:00 UTC".to_time.utc) do
      district = Fabricate(:district, zip: "12345")
      user = Fabricate.build(:user, name: "Uschi Müller", email: "test@example.com", city: "Dorf", zip: "54321", street: "Am Weiher 123", appendix: "2. OG", phone: "0178123456", date_of_birth: "31.12.2000")
      charge = Fabricate.build(:charge, tbnr: "142170", description: "Parken auf einem unbeschilderten Radweg")
      notice = Fabricate.build(:notice, user:, charge:, brand: "märzer", color: "black", registration: "HH AB 123", city: "Dorf", street: "Am Weiher 123", zip: "12345", district:, token: "xxxxxxx")
      notice.save!
      notice.photos.first.update!(key: "test.jpg")

      result = XmlGenerator.new.generate(notice, :winowig, files: ["test.jpg"])

      # file_fixture("winowig.xml").write(result)
      expect(winowig).to eql(result)
    end
  end
end
