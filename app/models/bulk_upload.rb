class BulkUpload < ActiveRecord::Base
  belongs_to :user
  has_many :notices, dependent: :nullify
  has_many_attached :photos

  enum status: {initial: 0, processing: 1, open: 2, done: 3}

  validates :photos, presence: :true, unless: ->() { done? }

  def purge_photo!(photo_id)
    photos.find(photo_id).purge_later

    update!(status: :done) if photos.blank?
  end
end
