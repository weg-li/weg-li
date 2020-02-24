class Scheduled::RestartJob < ApplicationJob
  def perform
    Rails.logger.info("reschedule aborted processors")
    Notice.analyzing.where('updated_at < ?', 2.minutes.ago).each do |notice|
      Rails.logger.info "restarting notice #{notice.id}"
      notice.analyze!
    end

    BulkUpload.processing.where('updated_at < ?', 5.minutes.ago).each do |bulk_upload|
      Rails.logger.info "restarting bulk #{bulk_upload.id}"
      bulk_upload.process!
    end
  end
end
