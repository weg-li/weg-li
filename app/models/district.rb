class District < ActiveRecord::Base
  validates :name, :zip, :email, presence: :true

  geocoded_by :geocode_address
  after_validation :geocode

  def self.from_zip(zip)
    find_by(zip: zip)
  end

  def self.legacy_by_zip(zip)
    district = from_zip(zip)
    return nil if district.blank?

    DistrictLegacy.new(district.name, district.name.parameterize, district.email, district.zip, district.latitude, district.longitude)
  end

  def geocode_address
    "#{zip}, #{name}, Deutschland"
  end

  def display_name
    "#{email} (#{zip} #{name})"
  end
end
