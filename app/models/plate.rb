# frozen_string_literal: true

class Plate < ApplicationRecord
  acts_as_api

  api_accessible :public_beta do |template|
    %i[
      name
      prefix
      zips
      created_at
      updated_at
    ].each { |key| template.add(key) }
  end

  validates :name, presence: true
  validates :prefix, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
  scope :search, ->(term) { where("name ILIKE :term OR prefix ILIKE :term", term: "%#{term}%") }

  def self.from_param(param)
    param = param.split("-").first || param
    find_by!(prefix: param)
  end

  def to_param
    "#{prefix}-#{name.parameterize}"
  end
end
