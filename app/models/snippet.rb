# frozen_string_literal: true

class Snippet < ApplicationRecord
  belongs_to :user

  validates :name, :content, presence: true

  scope :ordered, -> { order(:priority, :id) }
  scope :search, ->(term) { where("name ILIKE :term OR content ILIKE :term", term: "%#{term}%") }
end
