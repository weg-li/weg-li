class District < ActiveRecord::Base
  validates :name, :zip, :email, presence: :true

  geocoded_by :geocode_address
  after_validation :geocode

  has_many :notices

  def self.from_zip(zip)
    find_by(zip: zip)
  end

  def self.legacy_by_zip(zip)
    district = from_zip(zip)
    return nil if district.blank?

    DistrictLegacy.new(district.name, district.name.parameterize, district.email, district.zip, district.latitude, district.longitude)
  end

  def map_data
    {
      zoom: 13,
      latitude: latitude,
      longitude: longitude,
    }
  end

  def geocode_address
    "#{zip}, #{name}, Deutschland"
  end

  def display_name
    "#{email} (#{zip} #{name})"
  end

  def self.attach_prefix
    District.where(prefix: nil).limit(100).each do |district|
      prefix = Vehicle.zip_to_prefix[district.zip]
      if prefix.present?
        district.update_attribute(:prefix, prefix)
      else
        Rails.logger.info("no match for #{district.name}")
      end
    end
  end
end
