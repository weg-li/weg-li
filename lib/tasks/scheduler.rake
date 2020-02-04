namespace :scheduler do
  desc "reschedule aborted analyzers"
  task restart_analyzers: :environment do
    puts "restart analyzers"

    Notice.analyzing.where('updated_at > ?', 5.minutes.ago).each do |notice|
      puts "restarting notice #{notice.token}"
      notice.analyze!
    end

    BulkUpload.processing.where('updated_at > ?', 15.minutes.ago).each do |bulk_upload|
      puts "restarting bulk #{notice.token}"
      bulk_upload.analyze!
    end
  end

  desc "prerender variants"
  task prerender_variants: :environment do
    puts "prerender variants"

    User.where("date_part('day', created_at) = ?", Date.today.day).each_with_index do |user, i|
      puts "prerendering user #{user.token}"
      UserUploadJob.set(wait: i.minutes).perform_later(user)
    end
  end

  desc "daily job to make users activate"
  task send_activation_reminder: :environment do
    puts "send activation reminders"

    not_validated = User.user.where(validation_date: nil)
    not_validated.each do |user|
      if user.updated_at < 2.weeks.ago && user.notices.blank?
        puts "destroying unvalidated user #{user.id} #{user.name} #{user.email}"
        user.destroy!
      else
        puts "sending email validation to #{user.id} #{user.name} #{user.email}"
        UserMailer.validate(user).deliver_now
      end
    end
  end

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
    select notices.id, 2 * 3961 * asin(sqrt((sin(radians((districts.latitude - notices.latitude) / 2))) ^ 2 + cos(radians(notices.latitude)) * cos(radians(districts.latitude)) * (sin(radians((districts.longitude - notices.longitude) / 2))) ^ 2)) as distance from notices join districts on notices.district_id = districts.id where notices.incomplete = FALSE and notices.latitude IS NOT NULL and districts.latitude IS NOT NULL
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
