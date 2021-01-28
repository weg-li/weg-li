class Scheduled::GeocodingCleanupJob < ApplicationJob
  def perform
    Rails.logger.info "fixup for geocoding"

    Notice.shared.where(latitude: nil).each do |notice|
      notice.save!
    end

    query = "
    select * from (
    select notices.id, 2 * 3961 * asin(sqrt((sin(radians((districts.latitude - notices.latitude) / 2))) ^ 2 + cos(radians(notices.latitude)) * cos(radians(districts.latitude)) * (sin(radians((districts.longitude - notices.longitude) / 2))) ^ 2)) as distance from notices join districts on notices.zip = districts.zip where notices.incomplete = FALSE and notices.latitude IS NOT NULL and districts.latitude IS NOT NULL
    ) as res where res.distance > #{Geo::MAX_DISTANCE};
    "

    # clean it up
    cursor = Notice.connection.execute(query)
    cursor.each do |row|
      id = row['id']
      distance = row['distance']
      Rails.logger.info "distance for #{id} is > #{distance}"
      notice = Notice.find(id)
      notice.geocode
      notice.save(validate: false)
    end

    # run again so we have the actual failures for the notification
    cursor = Notice.connection.execute(query)
    cursor.each do |row|
      id = row['id']
      distance = row['distance']
      notice = Notice.find(id)

      notify("distance for #{id} is > #{distance} is #{notice.full_address} and district is #{notice.district.inspect}: https://www.weg.li/admin/notices/#{notice.token}")
    end
  end
end
