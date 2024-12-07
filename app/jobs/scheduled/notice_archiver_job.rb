# frozen_string_literal: true

class Scheduled::NoticeArchiverJob < ApplicationJob
  def perform
    Rails.logger.info "archiving notices"

    notices = Notice.where("created_at < ?", 4.years.ago).where(archived: false)
    notify "archiving #{notices.count} notices"
    notices.update_all(archived: true)
  end
end
