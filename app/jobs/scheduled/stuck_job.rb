class Scheduled::StuckJob < ApplicationJob
  def perform
    Rails.logger.warn("checking for stuck jobs")

    processes.each do |process|
      id = process.identity
      Rails.logger.warn("checking process #{id}")

      busy = process['busy']
      concurrent = process['concurrency']

      if busy >= concurrent
        Rails.logger.warn("process #{id} is busy ok with concurrent #{busy}/#{concurrent}")

        busy_workers = workers.select { |process, thread, msg| process == id }
        dead_workers = busy_workers.select { |process, thread, msg| msg['run_at'] < 5.minutes.ago }

        if dead_workers >= concurrent
          Rails.logger.warn("process #{id} has only dead jobs, killing it now")
          Sidekiq::Process.new(id).stop!
        else
          Rails.logger.warn("process #{id} has just #{dead_workers.size} dead jobs, #{busy_workers.size - dead_workers.size} busy")
        end
      else
        Rails.logger.warn("process #{id} is ok with concurrent #{busy}/#{concurrent}")
      end
    end
  end

  private

  def processes
    @processes ||= Sidekiq::ProcessSet.new
  end

  def workers
    @workers ||= Sidekiq::Workers.new
  end
end
