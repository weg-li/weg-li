require 'spec_helper'

describe Scheduled::RestartJob do
  context "perform" do
    it "should process the bulk-upload" do
      Fabricate.create(:notice, status: :analyzing, updated_at: 1.hour.ago)
      Fabricate.create(:bulk_upload, status: :processing, updated_at: 1.hour.ago)

      expect {
        expect {
          Scheduled::RestartJob.perform_now
        }.to have_enqueued_job(AnalyzerJob)
      }.to have_enqueued_job(BulkUploadJob)
    end
  end
end
