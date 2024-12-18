# frozen_string_literal: true

require "spec_helper"

describe Scheduled::NoticeArchiverJob do
  context "perform" do
    it "should archive notices" do
      Fabricate.create(:notice, created_at: 4.years.ago)
      Fabricate.create(:notice, created_at: 3.years.ago)
      Fabricate.create(:notice, created_at: 2.years.ago)

      expect do
        Scheduled::NoticeArchiverJob.perform_now
      end.to change { Notice.where(archived: true).count }.by(1)
    end
  end
end
