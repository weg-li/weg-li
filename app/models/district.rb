class District < ActiveRecord::Base
  validates :name, :zip, :email, presence: :true

  geocoded_by :zip
  after_validation :geocode

  def self.legacy_by_zip(zip)
    district = find_by(zip: zip)
    DistrictLegacy.new(district.name, district.name.parameterize, district.email, 15, district.latitude, district.longitude)
  end
end
