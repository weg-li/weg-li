# frozen_string_literal: true

class Scheduled::DataCleanupJob < ApplicationJob
  def perform
    Rails.logger.info "cleaning up data"

    data_sets = DataSet.where("created_at < ?", 6.month.ago)

    notify("cleaning up old data #{data_sets.count} data_sets")
    data_sets.delete_all

    data_sets = DataSet.joins("INNER JOIN notices ON notices.id = setable_id AND notices.status = 3").order(:created_at).where("data_sets.created_at < ?", 1.month.ago).limit(10_000)

    notify("cleaning up shared data #{data_sets.count} data_sets")
    data_sets.delete_all
  end
end
