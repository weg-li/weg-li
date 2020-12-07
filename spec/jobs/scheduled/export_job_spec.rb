require 'spec_helper'

describe Scheduled::ExportJob do
  let(:notice_export) { File.binread(file_fixture('notice_export.zip')) }

  context "perform" do
    it "should create a notice export" do
      travel_to('20.01.2020 15:00:00 UTC'.to_time.utc) do
        district = Fabricate.create(:district, zip: '22525')
        Fabricate.create(:notice, status: :shared, charge: 'Scheiße geparkt', street: 'Nazis boxen 42', city: 'Hamburg', zip: '22525', district: district)

        expect {
          Scheduled::ExportJob.perform_now
        }.to change { Export.count }.by(1)

        result = Export.last.archive.download
        # file_fixture('notice_export.zip').binwrite(result)
        expect(notice_export.size).to eql(result.size)
      end
    end

    let(:profile_export) { File.binread(file_fixture('profile_export.zip')) }

    it "should create a profile export" do
      travel_to('20.01.2020 15:00:00 UTC'.to_time.utc) do
        district = Fabricate.create(:district, zip: '22525')
        user = Fabricate.create(:user, token: '123')
        Fabricate.create(:notice, status: :shared, charge: 'Scheiße geparkt', street: 'Nazis boxen 42', city: 'Hamburg', zip: '22525', district: district, user: user)

        expect {
          Scheduled::ExportJob.perform_now(export_type: :profiles)
        }.to change { Export.count }.by(1)

        result = Export.last.archive.download
        file_fixture('profile_export.zip').binwrite(result)
        expect(profile_export.size).to eql(result.size)
      end
    end

    let(:photo_export) { File.binread(file_fixture('photo_export.zip')) }

    it "should create a photo export" do
      travel_to('20.01.2020 15:00:00 UTC'.to_time.utc) do
        notice = Fabricate.create(:notice, status: :shared, registration: 'HH PS 123', charge: 'Scheiße geparkt', brand: 'Nazis boxen 42', color: 'black')
        notice.photos.first.update!(key: '4qh62kv2eb3ihjruvqurubkog7eq.jpg')

        expect {
          Scheduled::ExportJob.perform_now(export_type: :photos)
        }.to change { Export.count }.by(1)

        result = Export.last.archive.download
        # file_fixture('photo_export.zip').binwrite(result)
        expect(photo_export.size).to eql(result.size)
      end
    end
  end
end
