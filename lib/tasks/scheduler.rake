namespace :scheduler do
  desc "trigger geocoding when it looks like its off"
  task fixup_geocoding: :environment do
    puts "fixup for geocoding"

    query = "
    select * from (
    select notices.id, 2 * 3961 * asin(sqrt((sin(radians((districts.latitude - notices.latitude) / 2))) ^ 2 + cos(radians(notices.latitude)) * cos(radians(districts.latitude)) * (sin(radians((districts.longitude - notices.longitude) / 2))) ^ 2)) as distance from notices join districts on notices.zip = districts.zip where notices.incomplete = FALSE and notices.latitude IS NOT NULL and districts.latitude IS NOT NULL
    ) as res where res.distance > 50;
    "
    cursor = Notice.connection.execute(query)
    cursor.each do |row|
      id = row['id']
      distance = row['distance']
      puts "distance for #{id} is > #{distance}"
      notice = Notice.find(id)
      puts "notice is #{notice.full_address} and district is #{notice.district.inspect}"
      notice.geocode
      notice.save(validate: false)
    end
  end
end
