class BulkUpload < ActiveRecord::Base
  belongs_to :user
  has_many :notices
  has_many_attached :photos

  validates :photos, presence: :true

  def status
    :open
  end
end
