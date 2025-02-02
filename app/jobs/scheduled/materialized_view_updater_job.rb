# frozen_string_literal: true

class Scheduled::MaterializedViewUpdaterJob < ApplicationJob
  def perform
    Rails.logger.info "refreshing views"

    Homepage.refresh
  end
end
