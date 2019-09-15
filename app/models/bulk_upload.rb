class BulkUpload < ActiveRecord::Base
  belongs_to :user
  has_many :notices, dependent: :nullify
  has_many_attached :photos

  validates :photos, presence: :true

  def status
    photos.present? ? :open : :done
  end
end
