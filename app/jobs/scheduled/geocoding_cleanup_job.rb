# frozen_string_literal: true

class Scheduled::GeocodingCleanupJob < ApplicationJob
  def perform
    Rails.logger.info "fixup for geocoding"

    Notice.shared.where(latitude: nil).each(&:save!)

    query =
      "
    SELECT * FROM (
      SELECT
      notices.id, 2 * 3961 * ASIN(SQRT((SIN(RADIANS((districts.latitude - notices.latitude) / 2))) ^ 2 + COS(RADIANS(notices.latitude)) * COS(RADIANS(districts.latitude)) * (SIN(RADIANS((districts.longitude - notices.longitude) / 2))) ^ 2)) AS distance
      FROM notices
      JOIN users ON notices.user_id = users.id AND users.access >= 0
      JOIN districts ON notices.zip = districts.zip
      WHERE
      notices.status = 3
      AND
      notices.latitude IS NOT NULL
      AND
      districts.latitude IS NOT NULL
    ) AS res WHERE res.distance > #{Geo::MAX_DISTANCE} LIMIT 100;
    "

    # clean it up
    cursor = Notice.connection.execute(query)
    cursor.each do |row|
      id = row["id"]
      distance = row["distance"]
      Rails.logger.info "distance for #{id} is > #{distance}"
      notice = Notice.find(id)
      notice.geocode
      notice.save(validate: false)
    end

    # clean it up again
    cursor = Notice.connection.execute(query)
    cursor.each do |row|
      id = row["id"]
      distance = row["distance"]
      Rails.logger.info "distance for #{id} is > #{distance}"
      notice = Notice.find(id)
      notice.city = notice.district.name
      notice.geocode
      notice.save(validate: false)
    end

    # run again so we have the actual failures for the notification
    cursor = Notice.connection.execute(query)
    cursor.each do |row|
      id = row["id"]
      distance = row["distance"]
      notice = Notice.find(id)

      notify(
        "distance for #{id} is > #{distance} is #{notice.full_address} and district is #{notice.district.inspect}: https://www.weg.li/admin/notices/#{notice.token}",
      )
    end
  end
end
