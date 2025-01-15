# frozen_string_literal: true

require "spec_helper"

describe PdfGenerator do
  let(:example) { File.binread(file_fixture("anzeige.pdf")) }

  before do
    stub_request(:get, /.*/).to_return(status: 200, body: file_fixture("mercedes.jpg").read)
  end

  it "handles the pdf generation" do
    travel_to("20.01.2020 15:00:00 UTC".to_time.utc) do
      district = Fabricate(:district, zip: "17098")
      user = Fabricate.build(:user, name: "Uschi Müller", email: "test@example.com", city: "Dorf", zip: "17098", street: "Am Weiher 123")
      charge = Fabricate.build(:charge, tbnr: "112474", description: "Parken auf einem unbeschilderten Radweg")
      notice = Fabricate.build(:notice, user:, charge:, brand: "BMW", color: "black", registration: "HH AB 123", city: "Dorf", street: "Am Weiher 123", zip: "17098", district:, token: "3004b58caa242b8ff9d79766f092a994")
      notice.save!

      result = PdfGenerator.new(quality: :original).generate(notice)

      # file_fixture("anzeige.pdf").binwrite(result)
      expect(example.size).to eql(result.size)
    end
  end

  it "handles weird characters" do
    broken_string = "Telefon: ‭015224026"
    notice = Fabricate(:notice, note: broken_string)

    expect { PdfGenerator.new.generate(notice) }.to_not raise_error
  end
end
