require 'spec_helper'

describe RestartJob do
  let(:notice) { Fabricate.create(:notice, status: :analyzing, updated_at: 1.hour.ago) }
  let(:bulk_upload) { Fabricate.create(:bulk_upload, status: :processing, updated_at: 1.hour.ago) }

  context "perform" do
    it "should process the bulk-upload" do
      expect {
        expect {
          RestartJob.perform_now
        }.to have_enqueued_job(AnalyzerJob)
      }.to have_enqueued_job(BulkUploadJob)
    end
  end
end
