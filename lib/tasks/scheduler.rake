namespace :scheduler do
  desc "reschedule aborted analyzers"
  task restart_analyzers: :environment do
    with_tracking do
      puts "restart analyzers"

      Notice.analyzing.where('updated_at > ?', 5.minutes.ago).each do |notice|
        puts "restarting #{notice.token}"
        notice.analyze!
      end
    end
  end

  desc "daily job to send reminders for open notices that are 2 weeks old"
  task send_notice_reminder: :environment do
    with_tracking do
      puts "send reminders"

      open_notices = Notice.for_reminder
      groups = open_notices.group_by(&:user)
      groups.each do |user, notices|
        UserMailer.reminder(user, notices).deliver_now
      end
    end
  end

  desc "trigger geocoding when it looks like its off"
  task fixup_geocoding: :environment do
    with_tracking do
      puts "fixup for geocoding"

      query = "
      select * from (
      select notices.id, 2 * 3961 * asin(sqrt((sin(radians((districts.latitude - notices.latitude) / 2))) ^ 2 + cos(radians(notices.latitude)) * cos(radians(districts.latitude)) * (sin(radians((districts.longitude - notices.longitude) / 2))) ^ 2)) as distance from notices join districts on notices.district_id = districts.id where notices.latitude IS NOT NULL and districts.latitude IS NOT NULL
      ) as res where res.distance > 100;
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

  private

  def with_tracking
    begin
      yield
    rescue => e
      ExceptionNotifier.notify_exception(e) if Rails.env.production?
      Rails.logger.error("exception during task invocation: #{e}\n#{e.backtrace.join("\n")}")
    end
  end
end
