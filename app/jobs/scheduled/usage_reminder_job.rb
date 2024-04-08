# frozen_string_literal: true

class Scheduled::UsageReminderJob < ApplicationJob
  def perform
    Rails.logger.info "deaktivate old users"

    not_using =
      User
        .left_joins(:notices)
        .where("notices.id IS NULL")
        .where("date_part('dow', users.updated_at) = ?", Date.today.wday)
        .where("users.updated_at < ?", 12.month.ago)
    not_using.each do |user|
      if user.disabled?
        Rails.logger.info "marking inactive user for deletion #{user.id} #{user.name} #{user.email}"
        user.update_attribute :access, :to_delete
      elsif user.updated_at < 13.month.ago
        Rails.logger.info "deactivating inactive user #{user.id} #{user.name} #{user.email}"
        user.update_attribute :access, :disabled
      else
        Rails.logger.info "activating user #{user.id} #{user.name} #{user.email}"
        UserMailer.activate(user).deliver_now
      end
    end
  end
end
