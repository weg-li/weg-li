# frozen_string_literal: true

require "spec_helper"

describe Scheduled::ExpiringReminderJob do
  context "perform" do
    it "should remind users of notices" do
      Fabricate.create(:notice, start_date: 6.weeks.ago, status: :open)

      expect do
        Scheduled::ExpiringReminderJob.perform_now
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should remind users of bulk_uploads" do
      Fabricate.create(:bulk_upload, created_at: 6.weeks.ago, status: :open)

      expect do
        Scheduled::ExpiringReminderJob.perform_now
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
