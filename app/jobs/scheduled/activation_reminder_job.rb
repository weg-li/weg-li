# frozen_string_literal: true

class Scheduled::ActivationReminderJob < ApplicationJob
  def perform
    Rails.logger.info 'send activation reminders'

    not_validated = User.user.where(validation_date: nil)
    not_validated.each do |user|
      if user.updated_at < 2.weeks.ago && user.notices.blank?
        Rails.logger.info "destroying unvalidated user #{user.id} #{user.name} #{user.email}"
        user.destroy!
      else
        Rails.logger.info "sending email validation to #{user.id} #{user.name} #{user.email}"
        UserMailer.validate(user).deliver_now
      end
    end
  end
end
