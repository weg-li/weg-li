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
