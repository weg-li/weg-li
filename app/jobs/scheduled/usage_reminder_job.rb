class Scheduled::UsageReminderJob < ApplicationJob
  def perform
    Rails.logger.info "deaktivate old users"

    not_using = User.active.left_joins(:notices).where('notices.id IS NULL').where("date_part('dow', users.updated_at) = ?", Date.today.wday).where('users.updated_at < ?', 3.month.ago)
    not_using.each do |user|
      if user.updated_at < 4.month.ago
        Rails.logger.info "deactivating inactive user #{user.id} #{user.name} #{user.email}"
        user.update! access: :disabled
      else
        Rails.logger.info "activating user #{user.id} #{user.name} #{user.email}"
        UserMailer.activate(user).deliver_now
      end
    end
  end
end
