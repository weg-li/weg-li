# frozen_string_literal: true

module RegistrationCountry
  extend ActiveSupport::Concern

  included do
    before_validation :infer_registration_country
    before_save :ensure_registration_country_for_storage
    after_save { @registration_country_assigned = false }
    validates :registration_country, inclusion: { in: ->(_notice) { VehicleCountry.codes } }
    validate :registration_country_matches_prefix
  end

  def registration_country=(value)
    @registration_country_assigned = true
    super(value.to_s.strip.upcase.presence || VehicleCountry::DEFAULT)
  end

  def display_registration
    return registration if registration.blank? || registration_country == VehicleCountry::DEFAULT || VehicleCountry.parse_registration(registration)

    "(#{registration_country}) #{registration}"
  end

  private

  def infer_registration_country
    return if @registration_country_assigned

    parsed = VehicleCountry.parse_registration(registration)
    if parsed && (new_record? || registration_changed?)
      self[:registration_country] = parsed.country.iso_code
    elsif registration_changed? && VehicleCountry.parse_registration(registration_in_database)
      self[:registration_country] = VehicleCountry::DEFAULT
    end
  end

  def registration_country_matches_prefix
    parsed = VehicleCountry.parse_registration(registration)
    errors.add(:registration_country, :invalid) if parsed && parsed.country.iso_code != registration_country
  end

  def ensure_registration_country_for_storage
    parsed = VehicleCountry.parse_registration(registration)
    return if VehicleCountry.find(registration_country) && (!parsed || parsed.country.iso_code == registration_country)

    errors.add(:registration_country, :invalid) if errors[:registration_country].empty?
    raise ActiveRecord::RecordInvalid, self
  end
end
