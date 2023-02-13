# frozen_string_literal: true

require "spec_helper"

describe Scheduled::ActivationReminderJob do
  context "perform" do
    it "should remind users" do
      Fabricate.create(:user, validation_date: nil)

      expect do
        Scheduled::ActivationReminderJob.perform_now
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should delete users" do
      Fabricate.create(:user, validation_date: nil, updated_at: 3.weeks.ago)

      expect do
        Scheduled::ActivationReminderJob.perform_now
      end.to change { User.count }.by(-1)
    end
  end
end
