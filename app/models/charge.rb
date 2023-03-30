# frozen_string_literal: true

class Charge < ApplicationRecord
  validates :tbnr, :description, presence: true
  validates :tbnr, length: { is: 6 }

  has_many :notices, foreign_key: :tbnr, primary_key: :tbnr
  has_many :charge_variants,
           -> { joins(:charge).where("charge_variants.date = charges.valid_from") },
           foreign_key: :table_id,
           primary_key: :variant_table_id

  scope :active, -> { where(valid_to: nil).where("fine > 0") }
  scope :ordered, -> { order(:tbnr, :valid_from) }
  scope :parking, -> { where(classification: 5) }
  scope :by_param, ->(param) { where(tbnr: parse_param(param)) }

  acts_as_api

  api_accessible :public_beta do |api|
    api.add(:tbnr)
    api.add(:description)
    api.add(:fine)
    api.add(:bkat)
    api.add(:penalty)
    api.add(:fap)
    api.add(:points)
    api.add(:valid_from)
    api.add(:valid_to)
    api.add(:implementation)
    api.add(:classification)
    api.add(:variant_table_id)
    api.add(:rule_id)
    api.add(:table_id)
    api.add(:required_refinements)
    api.add(:number_required_refinements)
    api.add(:max_fine)
    api.add(:created_at)
    api.add(:updated_at)
  end

  CLASSIFICATIONS = {
    0 => "sonstige",
    1 => "Lichtzeichen",
    2 => "Behinderung",
    3 => "Gefährdung",
    4 => "Unfall",
    5 => "Halt- und Parkverstoß",
    6 => "Geschwindigkeitsüberschreitung",
    7 => "Überladung",
    8 => "Alkohol und Rauschmittel",
    9 => "Abstandsmessung",
  }

  FAP = {
    "A" => "schwerwiegende Zuwiderhandlung bei Fahrerlaubnis auf Probe",
    "B" => "weniger schwerwiegende Zuwiderhandlung bei Fahrerlaubnis auf Probe",
  }

  FAVS = %w[112454 141312 112262 141174 141194 141245 112474 142103 141322]

  class << self
    def classification_name(classification)
      CLASSIFICATIONS[classification.to_i] || "-"
    end

    def from_param(param)
      by_param(param).ordered.first!
    end

    def parse_param(param)
      param.split("-").first || param
    end
  end

  def classification_name
    self.class.classification_name(classification)
  end

  def fap_description
    FAP[fap] || "-"
  end

  def to_param
    "#{tbnr}-#{description.parameterize}"
  end
end
