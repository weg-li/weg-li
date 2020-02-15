require 'spec_helper'

describe Scheduled::RestartJob do
  context "perform" do
    it "should process the bulk-upload" do
      notice = Fabricate.create(:notice, status: :analyzing)
      bulk_upload = Fabricate.create(:bulk_upload, status: :processing)

      notice.update_attribute(:updated_at, 5.minutes.ago)
      bulk_upload.update_attribute(:updated_at, 10.minutes.ago)

      expect {
        expect {
          Scheduled::RestartJob.perform_now
        }.to have_enqueued_job(AnalyzerJob)
      }.to have_enqueued_job(BulkUploadJob)
    end
  end
end
