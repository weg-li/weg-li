# frozen_string_literal: true

class Scheduled::StuckJob < ApplicationJob
  def perform
    Rails.logger.debug("checking for stuck jobs")

    processes.each do |process|
      identity = process.identity
      Rails.logger.debug("checking process #{identity}")

      busy = process["busy"]
      concurrent = process["concurrency"]

      if busy >= concurrent
        Rails.logger.debug(
          "process #{identity} is busy with #{busy} of #{concurrent}"
        )

        busy_workers = workers.select { |it, _thread, _msg| it == identity }
        dead_workers =
          busy_workers.select do |_process, _thread, msg|
            Time.at(msg["run_at"]) < 2.minutes.ago
          end
        dead = dead_workers.size

        if dead >= concurrent / 2
          notify(
            "process #{identity} has #{dead} of #{concurrent} dead jobs, killing it now! https://www.weg.li/sidekiq/busy?poll=true"
          )
          Sidekiq::Process.new("identity" => identity).stop!
        else
          notify(
            "process #{identity} has just #{dead} of #{concurrent} dead jobs, #{concurrent - dead} are busy. https://www.weg.li/sidekiq/busy?poll=true"
          )
        end
      else
        Rails.logger.debug(
          "process #{identity} is ok with #{busy} of #{concurrent}"
        )
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
