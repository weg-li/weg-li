# frozen_string_literal: true

require "spec_helper"

describe Scheduled::NoticeArchiverJob do
  context "perform" do
    it "should archive notices" do
      Fabricate.create(:notice, created_at: 5.years.ago, status: :open)
      Fabricate.create(:notice, created_at: 5.years.ago, status: :shared)
      Fabricate.create(:notice, created_at: 4.years.ago, status: :shared)
      Fabricate.create(:notice, created_at: 3.years.ago, status: :shared)
      Fabricate.create(:notice, created_at: 2.years.ago, status: :shared)

      expect do
        expect do
          Scheduled::NoticeArchiverJob.perform_now
        end.to change { Notice.where(archived: true).count }.by(2)
      end.to change { Notice.count }.by(-1)
    end
  end
end
