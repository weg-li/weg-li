# frozen_string_literal: true

class District < ApplicationRecord
  STATES = %w[
    Baden-Württemberg
    Bayern
    Berlin
    Brandenburg
    Bremen
    Hamburg
    Hessen
    Mecklenburg-Vorpommern
    Niedersachsen
    Nordrhein-Westfalen
    Rheinland-Pfalz
    Saarland
    Sachsen
    Sachsen-Anhalt
    Schleswig-Holstein
    Thüringen
  ]

  include Bitfields
  bitfield :flags, 1 => :personal_email

  enum :status, { active: 0, proposed: 1 }
  enum :config, { standard: 0, signature: 1, munich: 2, owi21: 3, hamburg: 4, winowig: 5 }

  has_many :notices, foreign_key: :zip, primary_key: :zip
  has_many :users, foreign_key: :zip, primary_key: :zip

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :zip, with: lambda(&:strip)

  validates :name, :email, :state, presence: true
  validates :zip, uniqueness: true, presence: true, zip: true
  validates :state, inclusion: { in: STATES }
  validates :email, "valid_email_2/email": { mx: true, disposable: true }

  geocoded_by :geocode_address, language: proc { |_model| I18n.locale }, no_annotations: true
  after_validation :geocode, if: :geocode_address_changed?

  attribute :reason, :string

  include Blockable
  self.blockables = %w[gmail.com web.de t-online.de gmx.de hotmail.de vodafone.de 1und1.de freenet.de aol.com yahoo.de yahoo.com outlook.de]

  acts_as_api

  api_accessible :public_beta do |template|
    %i[
      name
      zip
      email
      prefixes
      parts
      latitude
      longitude
      aliases
      personal_email
      state
      created_at
      updated_at
    ].each { |key| template.add(key) }
  end

  def map_data
    { zoom: 13, latitude:, longitude: }
  end

  def statistics(date = 100.years.ago)
    {
      notices: notices.since(date).count,
      active_users: User.where(id: notices.since(date).pluck(:user_id)).count,
      total_users: users.count,
    }
  end

  def geocode_address
    "#{zip}, #{name}, #{state}, Deutschland"
  end

  def geocode_address_changed?
    zip_changed? || name_changed? || state_changed?
  end

  def all_emails
    aliases.present? ? [email] + aliases : [email]
  end

  def display_name
    "#{zip} #{name}"
  end

  def display_email
    anonymize_email(email)
  end

  def anonymize_email(email)
    return "-" unless email.present?

    return email unless personal_email?

    address, domain = email.split("@")

    "#{address.first}#{'.' * (address.size - 2)}#{address.last}@#{domain}"
  end

  def display_aliases
    return "-" unless aliases.present?

    aliases.map { |email| anonymize_email(email) }.compact.join(", ")
  end

  def self.from_param(param)
    param = param.split("-").first || param
    find_by!(zip: param)
  end

  def to_param
    "#{zip}-#{name.parameterize}"
  end
end
