# frozen_string_literal: true

require "spec_helper"

describe Scheduled::DataDropperJob do
  context "perform" do
    it "should archive notices" do
      Fabricate.create(:notice, created_at: 6.years.ago, archived: true)
      Fabricate.create(:notice, created_at: 5.years.ago, archived: true)
      Fabricate.create(:notice, created_at: 4.years.ago, archived: true)

      expect do
        Scheduled::DataDropperJob.perform_now
      end.to have_enqueued_job(ActiveStorage::PurgeJob).exactly(2).times
    end
  end
end
