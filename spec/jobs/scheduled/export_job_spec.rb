# frozen_string_literal: true

require "spec_helper"

describe Scheduled::ExportJob do
  let(:notice_export) { File.binread(file_fixture("notice_export.zip")) }

  context "perform" do
    it "should create a notice export" do
      travel_to("20.01.2020 15:00:00 UTC".to_time.utc) do
        district = Fabricate.create(:district, zip: "22525")
        charge = Fabricate.build(:charge, tbnr: "142170", description: "Scheiße geparkt")
        Fabricate.create(:notice, status: :shared, charge:, street: "Nazis boxen 42", city: "Hamburg", zip: "22525", district:)

        expect do
          Scheduled::ExportJob.perform_now
        end.to change { Export.count }.by(1)

        result = Export.last.archive.download
        # file_fixture("notice_export.zip").binwrite(result)
        expect(notice_export.size).to eql(result.size)

        Zip::File.open_buffer(result) do |zip_file|
          zip_file.each do |entry|
            expect(entry.get_input_stream.read).to eql(File.read(file_fixture(entry.name)))
          end
        end
      end
    end
  end
end
