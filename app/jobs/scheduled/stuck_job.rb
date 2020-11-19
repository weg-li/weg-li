class Scheduled::StuckJob < ApplicationJob
  def perform
    Rails.logger.debug("checking for stuck jobs")

    processes.each do |process|
      id = process.identity
      Rails.logger.debug("checking process #{id}")

      busy = process['busy']
      concurrent = process['concurrency']

      if busy >= concurrent
        Rails.logger.debug("process #{id} is busy with #{busy} of #{concurrent}")

        busy_workers = workers.select { |process, thread, msg| process == id }
        dead_workers = busy_workers.select { |process, thread, msg| Time.at(msg['run_at']) < 2.minutes.ago }
        dead = dead.size


        if dead >= concurrent / 2
          notify("process #{id} has #{dead} of #{concurrent} dead jobs, killing it now!")
          Sidekiq::Process.new(id).stop!
        else
          notify("process #{id} has just #{dead} of #{concurrent} dead jobs, #{concurrent - dead} still busy")
        end
      else
        Rails.logger.debug("process #{id} is ok with #{busy} of #{concurrent}")
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
