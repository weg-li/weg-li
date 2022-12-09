# frozen_string_literal: true

class Scheduled::AnalyticsJob < ApplicationJob
  def perform
    Rails.logger.debug("checking incoming answers")

    replies =
      Reply
        .joins(:notice)
        .where("replies.created_at > ?", 1.day.ago)
        .group("notices.city")
        .order(count_all: :desc)
        .limit(10)
        .count

    notify(
      "Replies last 24 hours #{replies.map { |city, count| "#{city}: #{count}" }.join(", ")}"
    )
  end
end
