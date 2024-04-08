# frozen_string_literal: true

require "spec_helper"

describe Scheduled::UsageReminderJob do
  context "perform" do
    it "should remind users" do
      Fabricate.create(:user, updated_at: 53.weeks.ago)

      expect do
        Scheduled::UsageReminderJob.perform_now
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should disable users" do
      Fabricate.create(:user, updated_at: 57.weeks.ago)

      expect do
        Scheduled::UsageReminderJob.perform_now
      end.to change { User.disabled.count }.by(1)
    end

    it "should mark users for deletion" do
      Fabricate.create(:user, updated_at: 57.weeks.ago, access: :disabled)

      expect do
        Scheduled::UsageReminderJob.perform_now
      end.to change { User.to_delete.count }.by(1)
    end
  end
end
