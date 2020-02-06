class Scheduled::RestartJob < ApplicationJob
  def perform
    Rails.logger.info("reschedule aborted processors")
    Notice.analyzing.where('updated_at > ?', 5.minutes.ago).each do |notice|
      puts "restarting notice #{notice.token}"
      notice.analyze!
    end

    BulkUpload.processing.where('updated_at > ?', 15.minutes.ago).each do |bulk_upload|
      puts "restarting bulk #{notice.token}"
      bulk_upload.analyze!
    end
  end
end
