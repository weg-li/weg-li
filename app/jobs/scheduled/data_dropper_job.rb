# frozen_string_literal: true

class Scheduled::DataDropperJob < ApplicationJob
  def perform
    max = 5_000
    since = 40.months.ago
    Rails.logger.info "dropping max #{max} photos for old archived notices since #{since}"
    notices = Notice.archived.joins(:photos_attachments).where("notices.created_at < ?", since).with_attached_photos.limit(max)
    notify "actually dropping photos from #{notices.count} notices"
    notices.each do |notice|
      notice.photos.each(&:purge_later)
    end
  end
end
