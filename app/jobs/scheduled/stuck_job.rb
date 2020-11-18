class Scheduled::StuckJob < ApplicationJob
  def perform
    Rails.logger.warn("checking for stuck jobs")

    processes.each do |process|
      id = process.identity
      Rails.logger.warn("checking process #{id}")

      if process.busy >= process.concurrency
        Rails.logger.warn("process #{id} is busy ok with concurrent #{process.busy}/#{process.concurrent}")
        busy = workers.select { |process, thread, msg| process == id }
        hang = busy.select { |process, thread, msg| msg['run_at'] < 5.minutes.ago }
        if hang >= process.concurrency
          Rails.logger.warn("process #{id} has only hanging jobs, killing it now")
          # Sidekiq::Process.new(id).stop!
        else
          Rails.logger.warn("process #{id} has just #{hang.size} hanging jobs, #{busy.size - hang.size} busy")
        end
      else
        Rails.logger.warn("process #{id} is ok with concurrent #{process.busy}/#{process.concurrent}")
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
