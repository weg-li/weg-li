# frozen_string_literal: true

class Brand < ApplicationRecord
  enum kind: { car: 0, truck: 1, bike: 2, scooter: 3, van: 4 }
  enum status: { active: 0, proposed: 1 }

  has_many :notices, foreign_key: :brand, primary_key: :name

  before_validation :defaults

  validates :name, :token, :kind, presence: true
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
    def in_brands?(text, brands)
      brands.find { |entry| return false if entry.falsepositives.find { |ali| text == ali.strip.downcase } }

      res = brands.find { |entry| text == entry.name.strip.downcase }
      return res.name, 1.0 if res.present?

      res = brands.find { |entry| entry.aliases.find { |ali| text == ali.strip.downcase } }
      return [res.name, 1.0] if res.present?

      res = brands.find { |entry| text.match?(entry.name.strip.downcase) }
      return res.name, 0.8 if res.present?

      res = brands.find { |entry| entry.models.find { |model| model =~ /\D{3,}/ && text == model.strip.downcase } }
      [res.name, 0.5] if res.present?
    end

    def brand?(text)
      text = text.strip.downcase

      kinds.each_key do |kind|
        res = in_brands?(text, send(kind))
        return res if res
      end
      nil # rubocop:disable Style/ReturnNilInPredicateMethodDefinition
    end

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
