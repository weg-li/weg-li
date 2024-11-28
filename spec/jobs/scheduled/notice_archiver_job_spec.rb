# frozen_string_literal: true

require "spec_helper"

describe Scheduled::NoticeArchiverJob do
  context "perform" do
    it "should archive notices" do
      Fabricate.create(:notice, created_at: 5.years.ago)
      Fabricate.create(:notice, created_at: 37.month.ago)
      Fabricate.create(:notice, created_at: 35.month.ago)

      expect do
        Scheduled::NoticeArchiverJob.perform_now
      end.to change { Notice.where(archived: true).count }.by(2)
    end
  end
end
