require 'spec_helper'

describe Scheduled::RestartJob do
  context "perform" do
    it "should restart the jobs" do
      notice = Fabricate.create(:notice, status: :analyzing)
      notice.update_attribute(:updated_at, 5.minutes.ago)

      expect {
        Scheduled::RestartJob.perform_now
      }.to have_enqueued_job(AnalyzerJob)
    end
  end
end
