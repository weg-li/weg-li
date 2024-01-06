# frozen_string_literal: true

class Scheduled::DataCleanupJob < ApplicationJob
  def perform
    Rails.logger.info "cleaning up data"

    data_sets = DataSet.where("created_at < ?", 6.month.ago)

    notify("cleaning up data #{data_sets.count} data_sets")
    data_sets.destroy_all
  end
end
