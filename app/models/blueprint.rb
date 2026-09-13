# frozen_string_literal: true

class Blueprint < ApplicationRecord
  include Details

  belongs_to :user
  has_many :notices, dependent: :nullify
  belongs_to :charge, -> { order(valid_from: :desc) }, optional: true, foreign_key: :tbnr, primary_key: :tbnr

  validates :name, presence: true

  scope :ordered, -> { order(name: :desc, created_at: :asc) }
  scope :search, ->(term) { where("name ILIKE :term OR note ILIKE :term", term: "%#{term}%") }
end
