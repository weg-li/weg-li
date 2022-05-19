class Scheduled::RestartJob < ApplicationJob
  def perform
    Rails.logger.info("reschedule aborted processors")
    Notice.analyzing.where('updated_at < ?', 2.minutes.ago).each do |notice|
      Rails.logger.info "restarting notice #{notice.id}"
      notice.analyze!
    end
  end
end
