require 'csv'

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

  def self.zips
    # osm_id,ort,plz,bundesland
    @zips ||= CSV.parse(File.read('config/data/zips.csv'), headers: true)
  end

  def self.extend_data
    zips.each do |row|
      zip = row['plz']
      district = from_zip(zip)
      if district.present?
        Rails.logger.info("found #{zip}: #{district.id}")
      else
        source = District.where('name = :name AND zip LIKE :zip', name: row['ort'], zip: "#{zip.first}%").first
        if source.present?
          Rails.logger.info("found source for #{zip}: #{source.id}")
          district = source.dup
          district.zip = zip
          district.osm_id = row['osm_id']
          district.state = row['bundesland']
          district.prefix = zip_to_prefix[zip]
          district.save!
        else
          Rails.logger.info("could not find anything for #{zip}")
        end
      end
    end
  end

  def self.opengeodb
    @opengeodb ||= CSV.parse(File.read('config/data/opengeodb.csv'), col_sep: "\t", quote_char: nil, headers: true)
  end

  def self.zip_to_plate_prefix_mapping
    @zip_to_plate_prefix_mapping ||= opengeodb.each_with_object({}) do |entry, hash|
      next unless entry['plz']

      zips = entry['plz'].split(',')
      zips.each { |zip| hash[zip] = entry['kz'] if entry['kz'] }
    end.to_h
  end

  def self.zip_to_prefix
    @zip_to_prefix ||= JSON.load(Rails.root.join('config/data/zip_to_prefix.json'))
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
