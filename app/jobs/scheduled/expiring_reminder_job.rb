# frozen_string_literal: true

class Scheduled::ExpiringReminderJob < ApplicationJob
  def perform
    Rails.logger.info 'send reminders'

    open_notices = Notice.for_reminder
    groups = open_notices.group_by(&:user)
    groups.each do |user, notices|
      Rails.logger.info "reminding user for notices #{user.id}"
      UserMailer.reminder(user, notices.pluck(:id)).deliver_now
    end

    open_bulk_uploads = BulkUpload.for_reminder
    groups = open_bulk_uploads.group_by(&:user)
    groups.each do |user, bulk_uploads|
      Rails.logger.info "reminding user for bulk_uploads #{user.id}"
      UserMailer.reminder_bulk_upload(user, bulk_uploads.pluck(:id)).deliver_now
    end
  end
end
