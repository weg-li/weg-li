class Snippet < ApplicationRecord
  belongs_to :user

  validates :name, :content, presence: true

  scope :search, -> (term) { where('name ILIKE :term OR content ILIKE :term', term: "%#{term}%") }
end
