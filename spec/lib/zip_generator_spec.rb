# frozen_string_literal: true

require "spec_helper"

describe ZipGenerator do
  let(:example) { File.read(file_fixture("winowig.zip")) }

  before do
    stub_request(:get, /images\.weg\.li/).to_return(status: 200, body: file_fixture("truck.jpg").read)
  end

  it "handles the zip generation" do
    travel_to("12.11.2024 11:00:00 UTC".to_time.utc) do
      district = Fabricate(:district, zip: "12345")
      user = Fabricate.build(:user, name: "Uschi Müller", email: "test@example.com", city: "Dorf", zip: "54321", street: "Am Weiher 123", appendix: "2. OG", phone: "0178123456", date_of_birth: "31.12.2000")
      charge = Fabricate.build(:charge, tbnr: "142170", description: "Parken auf einem unbeschilderten Radweg")
      notice = Fabricate.build(:notice, user:, charge:, brand: "märzer", color: "black", registration: "HH AB 123", city: "Dorf", street: "Am Weiher 123", zip: "12345", district:, token: "123456")
      notice.save!
      notice.photos.first.update!(key: "test.jpg")

      result = ZipGenerator.new.generate(notice)

      # file_fixture("winowig.zip").binwrite(result.read)

      Zip::File.open_buffer(result) do |zip_file|
        zip_file.each do |entry|
          actual = entry.get_input_stream.read.force_encoding("UTF-8")
          expected = File.read(file_fixture("winowig/#{entry.name}"))
          expect(actual).to eql(expected)
        end
      end
    end
  end
end
