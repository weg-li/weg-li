require 'spec_helper'

describe Scheduled::RerenderJob do
  context "perform" do
    it "should restart the jobs" do
      user = Fabricate.create(:user)
      notice = Fabricate.create(:notice, user: user)
      bulk_upload = Fabricate.create(:bulk_upload, user: user)

      expect {
        Scheduled::RerenderJob.perform_now
      }.to have_enqueued_job(ThumbnailerJob).exactly(:twice)
    end
  end
end
