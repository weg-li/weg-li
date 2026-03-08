# frozen_string_literal: true

class Scheduled::NoticeArchiverJob < ApplicationJob
  def perform
    duration = 4.years.ago
    Rails.logger.info "archiving notices since #{duration}"

    notices = Notice.where("created_at < ?", duration).where(archived: false)
    notify "archiving #{notices.count} notices"
    notices.update_all(archived: true)

    notices = Notice.where("created_at < ?", duration).not_shared
    notify "deleting #{notices.count} trash notices"
    notices.destroy_all
  end
end
