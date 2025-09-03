# frozen_string_literal: true

class ZipValidator < ActiveModel::EachValidator
  class << self
    def valid?(zip)
      return false if zip.blank?
      return false if zip !~ /\d{5}/

      zips.include?(zip)
    end

    def zips
      @zips ||= read_zips
    end

    private

    def read_zips
      zips_and_city = CSV.parse(File.read("config/data/PLZ_Ort_Landkreis_Bundesland_Mapping_DE.csv"), headers: true, col_sep: ";")
      zips_and_city.pluck("PLZ").uniq.compact
    end
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :on_zip) unless self.class.valid?(value)
  end
end
