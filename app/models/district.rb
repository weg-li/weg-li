class District < ActiveRecord::Base
  include Bitfields
  bitfield :flags, 1 => :personal_email

  geocoded_by :geocode_address
  after_validation :geocode

  acts_as_api

  api_accessible :public_beta do |template|
    %i(name zip email prefix latitude longitude aliases personal_email created_at updated_at).each { |key| template.add(key) }
  end

  validates :name, :zip, :email, presence: true
  validates :zip, uniqueness: true

  has_many :notices, foreign_key: :zip, primary_key: :zip

  def self.from_zip(zip)
    find_by(zip: zip)
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
      users: User.where(id: notices.since(date).pluck(:user_id)).count,
    }
  end

  def geocode_address
    "#{zip}, #{name}, Deutschland"
  end

  def all_emails
    aliases.present? ? [email] + aliases : [email]
  end

  def display_name
    "#{email} (#{zip} #{name})"
  end

  def display_email
    anonymize_email(email)
  end

  def shit_hole_munich?
    all_emails.any? { |email| email =~ /polizei.bayern.de/ }
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
end
