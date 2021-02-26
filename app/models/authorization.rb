class Authorization < ApplicationRecord
  belongs_to :user

  validates :uid, :provider, presence: true
  validates :uid, uniqueness: {scope: :provider}
  validates :provider, uniqueness: {scope: :user}
end
