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
      zips_and_city = CSV.parse(File.read("config/data/zips_and_city.csv"), headers: true)
      zips_and_city.pluck("PLZ").compact
    end
  end

  def validate_each(record, attribute, value)
    record.errors.add(attribute, :on_zip) unless self.class.valid?(value)
  end
end
