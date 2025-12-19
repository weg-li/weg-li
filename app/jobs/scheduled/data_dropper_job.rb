# frozen_string_literal: true

class Scheduled::DataDropperJob < ApplicationJob
  def perform
    Rails.logger.info "dropping photos for old archived notices"

    max = 5_000
    notices = Notice.archived.joins(:photos_attachments).where("notices.created_at < ?", 5.years.ago).with_attached_photos.limit(max)
    notify "dropping photos from #{notices.count} notices"
    notices.each do |notice|
      notice.photos.each(&:purge_later)
    end
  end
end
