# frozen_string_literal: true

require "spec_helper"

describe "notice registration countries" do
  it "defaults to Germany in the model and database" do
    expect(Notice.new.registration_country).to eq("DE")
    expect(Notice.columns_hash.fetch("registration_country").default).to eq("DE")
    expect(Notice.columns_hash.fetch("registration_country").null).to be(false)
  end

  it "stores an explicitly selected country separately from the plate" do
    notice = Fabricate(:notice, registration: "AB-123-CD", registration_country: "fr")
    expect(notice.reload.registration_country).to eq("FR")
    expect(notice.registration).to eq("AB-123-CD")
    expect(notice.display_registration).to eq("(FR) AB-123-CD")
    expect(notice.owi21_args).to include(KFZ_Kennzeichen: "AB-123-CD", KFZ_Kennzeichen_Nation: "F", KFZ_Kennzeichen_Merkmal: "6")
  end

  it "infers the country from legacy input without changing the registration" do
    notice = Fabricate(:notice, registration: "(PL) PL-A 1233")
    expect(notice.reload.registration_country).to eq("PL")
    expect(notice.registration).to eq("(PL) PL-A 1233")
    expect(notice.display_registration).to eq("(PL) PL-A 1233")
    notice.update!(registration: "(FR) AB-123-CD")
    expect(notice.reload.registration_country).to eq("FR")
    notice.update!(registration: "HH AB 123")
    expect(notice.reload.registration_country).to eq("DE")
  end

  it "retains the selected foreign country when editing a plain plate" do
    notice = Fabricate(:notice, registration: "AB-123-CD", registration_country: "FR")
    notice.update!(registration: "XY-456-ZZ")
    expect(notice.reload.registration_country).to eq("FR")
  end

  it "allows an explicit return to Germany" do
    notice = Fabricate(:notice, registration: "AB-123-CD", registration_country: "FR")
    notice.update!(registration: "HH AB 123", registration_country: "DE")
    expect(notice.reload.display_registration).to eq("HH AB 123")
  end

  it "rejects conflicting country fields and legacy prefixes" do
    notice = Fabricate.build(:notice, registration: "(PL) ABC 123", registration_country: "DE")
    expect(notice).not_to be_valid
    expect(notice.errors[:registration_country]).to be_present
    expect { notice.save_incomplete! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "does not store an unsupported country even on an incomplete draft" do
    notice = Fabricate.build(:notice, registration_country: "UNKNOWN")
    expect(notice).not_to be_valid
    expect { notice.save_incomplete! }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "keeps same-day duplicate checks separate across registration countries" do
    notice = Fabricate(:notice, registration: "ABC 123", registration_country: "DE")
    foreign = Fabricate(:notice, user: notice.user, registration: "ABC 123", registration_country: "PL", start_date: notice.start_date)
    expect(notice.date_doubles).not_to include(foreign)
  end

  it "keeps the country visible in email and report details" do
    notice = Fabricate(:notice, registration: "АА 1234 ВВ", registration_country: "UA")
    text = ApplicationController.renderer.render(partial: "notice_mailer/details", formats: [:text], locals: { notice:, user: notice.user })
    expect(text).to include("(UA) АА 1234 ВВ")
    xml = Nokogiri::XML(XmlGenerator.new.generate(notice, :owi21))
    vehicle = xml.at_xpath("//owi:Bestand", "owi" => "http://www.owi21.de")
    expect(vehicle["KFZ_Kennzeichen"]).to eq("АА 1234 ВВ")
    expect(vehicle["KFZ_Kennzeichen_Nation"]).to eq("UA")
  end
end
