# frozen_string_literal: true

require "spec_helper"

describe UserExportJob do
  let(:notice_export) { File.binread(file_fixture("notice_user_export.zip")) }

  context "perform" do
    it "should create a notice export" do
      travel_to("20.01.2024 15:00:00 UTC".to_time.utc) do
        district = Fabricate.create(:district, zip: "22525")
        charge = Fabricate.build(:charge, tbnr: "142170", description: "Scheiße geparkt")
        notice = Fabricate.create(:notice, status: :shared, charge:, street: "Nazis boxen 42", city: "Hamburg", zip: "22525", district:)

        expect do
          expect do
            UserExportJob.perform_now(Export.new(user: notice.user))
          end.to change { Export.count }.by(1)
        end.to have_enqueued_mail(UserMailer, :export)

        result = Export.last.archive.download
        file_fixture("notice_user_export.zip").binwrite(result)
        expect(notice_export.size).to eql(result.size)
      end
    end
  end
end
