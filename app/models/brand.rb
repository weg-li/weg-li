# frozen_string_literal: true

class Brand < ApplicationRecord
  enum status: { car: 0, truck: 1, bike: 2, scooter: 3 }

  has_many :notices, foreign_key: :brand, primary_key: :name

  validates :name, :token, presence: true

  scope :ordered, -> { order(:name) }

  acts_as_api

  api_accessible :public_beta do |api|
    api.add(:name)
    api.add(:token)
    api.add(:kind)
    api.add(:models)
    api.add(:aliases)
    api.add(:created_at)
    api.add(:updated_at)
  end

  class << self
    def from_param(param)
      find_by!(token: param)
    end
  end

  def to_param
    "#{name.parameterize}"
  end
end
