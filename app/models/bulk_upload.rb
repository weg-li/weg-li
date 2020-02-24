class BulkUpload < ActiveRecord::Base
  belongs_to :user
  has_many :notices, dependent: :nullify
  has_many_attached :photos

  enum status: {initial: 0, importing: 4, processing: 1, open: 2, done: 3, error: -99}

  validates :photos, presence: :true, unless: ->() { done? || importing? || error? }
  validates :shared_album_url, presence: :true, if: ->() { importing? }

  def self.for_reminder
    open.joins(:user).where(created_at: [(21.days.ago.beginning_of_day)..(14.days.ago.end_of_day)]).merge(User.not_disable_reminders).merge(User.active)
  end

  def process!
    update! status: :processing

    BulkUploadJob.perform_later(self)
  end

  def ordered_photos(order_column = 'filename', order_direction = 'asc')
    case order_column
    when 'filename'
      photos_attachments.joins(:blob).order('active_storage_blobs.filename' => order_direction)
    else
      photos_attachments.joins(:blob).order('active_storage_blobs.created_at' => order_direction)
    end
  end

  def purge_photo!(photo_id)
    photos.find(photo_id).purge_later

    update!(status: :done) if photos.blank?
  end
end
