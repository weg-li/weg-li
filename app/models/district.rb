class District < ActiveRecord::Base
  STATES = [
    'Baden-Württemberg',
    'Bayern',
    'Berlin',
    'Brandenburg',
    'Bremen',
    'Hamburg',
    'Hessen',
    'Mecklenburg-Vorpommern',
    'Niedersachsen',
    'Nordrhein-Westfalen',
    'Rheinland-Pfalz',
    'Saarland',
    'Sachsen',
    'Sachsen-Anhalt',
    'Schleswig-Holstein',
    'Thüringen',
  ]

  include Bitfields
  bitfield :flags, 1 => :personal_email

  enum status: {active: 0, proposed: 1}
  enum config: {standard: 0, winowig: 1, munich: 2, signature: 3}

  has_many :notices, foreign_key: :zip, primary_key: :zip
  has_many :users, foreign_key: :zip, primary_key: :zip

  validates :name, :zip, :email, :state, presence: true
  validates :zip, uniqueness: true
  validates :state, inclusion: {in: STATES}

  geocoded_by :geocode_address
  after_validation :geocode

  acts_as_api

  api_accessible :public_beta do |template|
    %i(name zip email prefixes latitude longitude aliases personal_email created_at updated_at).each { |key| template.add(key) }
  end

  api_accessible :wegeheld do |template|
    template.add :id
    template.add :name
    template.add :email
    template.add :zip, as: :postalcode
  end

  def self.from_zip(zip)
    active.find_by(zip: zip)
  end

  def map_data
    {
      zoom: 13,
      latitude: latitude,
      longitude: longitude,
    }
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
    return '-' unless email.present?

    return email unless personal_email?

    address, domain = email.split('@')

    "#{address.first}#{'.' * (address.size - 2)}#{address.last}@#{domain}"
  end

  def display_aliases
    return '-' unless aliases.present?

    aliases.map {|email| anonymize_email(email) }.compact.join(', ')
  end

  def self.from_param(zip)
    find_by!(zip: zip)
  end

  def to_param
    zip
  end
end
