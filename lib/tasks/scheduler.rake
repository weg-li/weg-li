namespace :scheduler do
  desc "daily job to deaktivate old users"
  task deactivate_old_users: :environment do
    puts "deaktivate old users"

    not_using = User.left_joins(:notices).where('notices.id IS NULL').where("date_part('day', users.created_at) = ?", Date.today.day)
    not_using.each do |user|
      if user.updated_at < 2.month.ago
        puts "deactivating inactive user #{user.id} #{user.name} #{user.email}"
        user.update! access: :disabled
      else
        puts "activating user #{user.id} #{user.name} #{user.email}"
        UserMailer.activate(user).deliver_now
      end
    end
  end

  desc "daily job to send reminders for open notices that are 2 weeks old"
  task send_notice_reminder: :environment do
    puts "send reminders"

    open_notices = Notice.for_reminder
    groups = open_notices.group_by(&:user)
    groups.each do |user, notices|
      UserMailer.reminder(user, notices.pluck(:id)).deliver_now
    end
  end

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
