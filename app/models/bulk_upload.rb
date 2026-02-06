# frozen_string_literal: true

class BulkUpload < ApplicationRecord
  belongs_to :user
  has_many :notices, dependent: :nullify
  has_many_attached :photos

  enum :status, {
    initial: 0,
    processing: 1,
    open: 2,
    done: 3,
    importing: 4,
    error: -99,
  }

  validates :photos, presence: true, unless: -> { done? || importing? || error? }
  validates :shared_album_url, presence: true, if: -> { importing? }

  def photos=(attachables)
    attachables = Array(attachables).compact_blank
    # BC config.active_storage.replace_on_assign_to_many set to true before upgrading
    if attachables.any?
      attachment_changes["photos"] = ActiveStorage::Attached::Changes::CreateMany.new("photos", self, photos.blobs + attachables)
    end
  end

  def self.for_reminder
    range = [(21.days.ago.beginning_of_day)..(14.days.ago.end_of_day)]
    open.joins(:user).where(created_at: range).merge(User.not_disable_reminders).merge(User.active)
  end

  def purge_photo!(photo_id)
    photos.find(photo_id).purge_later

    update!(status: :done) if photos.blank?
  end
end
