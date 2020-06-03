require 'spec_helper'

describe Scheduled::UsageReminderJob do
  context "perform" do
    it "should remind users" do
      Fabricate.create(:user, updated_at: 14.weeks.ago)

      expect {
        Scheduled::UsageReminderJob.perform_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should disable users" do
      Fabricate.create(:user, updated_at: 18.weeks.ago)

      expect {
        Scheduled::UsageReminderJob.perform_now
      }.to change { User.disabled.count }.by(1)
    end
  end
end
