require 'spec_helper'

describe Scheduled::ActivationReminderJob do
  context "perform" do
    it "should remind users" do
      Fabricate.create(:user, validation_date: nil)

      expect {
        Scheduled::ActivationReminderJob.perform_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should delete users" do
      Fabricate.create(:user, validation_date: nil, updated_at: 3.weeks.ago)

      expect {
        Scheduled::ActivationReminderJob.perform_now
      }.to change { User.count }.by(-1)
    end
  end
end
