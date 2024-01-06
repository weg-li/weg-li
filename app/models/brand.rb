# frozen_string_literal: true

class Brand < ApplicationRecord
  enum kind: { car: 0, truck: 1, bike: 2, scooter: 3 }
  enum status: { active: 0, proposed: 1 }

  has_many :notices, foreign_key: :brand, primary_key: :name

  before_validation :defaults

  validates :name, :token, presence: true
  validates :token, uniqueness: true

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
    name.parameterize
  end

  def defaults
    self.token ||= to_param
  end
end
