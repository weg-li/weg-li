class Scheduled::GeocodingCleanupJob < ApplicationJob
  def perform
    Rails.logger.info "fixup for geocoding"

    query = "
    select * from (
    select notices.id, 2 * 3961 * asin(sqrt((sin(radians((districts.latitude - notices.latitude) / 2))) ^ 2 + cos(radians(notices.latitude)) * cos(radians(districts.latitude)) * (sin(radians((districts.longitude - notices.longitude) / 2))) ^ 2)) as distance from notices join districts on notices.zip = districts.zip where notices.incomplete = FALSE and notices.latitude IS NOT NULL and districts.latitude IS NOT NULL
    ) as res where res.distance > 50;
    "

    cursor = Notice.connection.execute(query)
    cursor.each do |row|
      id = row['id']
      distance = row['distance']
      Rails.logger.info "distance for #{id} is > #{distance}"
      notice = Notice.find(id)
      Rails.logger.info "notice is #{notice.full_address} and district is #{notice.district.inspect}"
      notice.geocode
      notice.save(validate: false)
    end

    cursor = Notice.connection.execute(query)
    notice_ids = cursor.pluck(:id)
    SystemMailer.geocoding(notice_ids) unless notice_ids.blank?
  end
end
