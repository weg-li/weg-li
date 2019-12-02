class HomeController < ApplicationController
  def index
  end

  def map
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    @district = params[:district] || current_user&.city || 'Hamburg'

    @notices = Notice.shared.since(@since.days.ago).joins(:district).where(districts: {name: @district})
    @active = @notices.map(&:user_id).uniq.size
    @default_district = District.find_by(name: @district) || District.first
  end

  def stats
    @months = 6

    @user_stats = User.count_by_month(User.active, months: @months)
    @user_sums = User.sum_by_month(User.active, months: @months)
    @active_user_stats = User.count_by_month(User.active.joins(:notices), months: @months)
    @notice_stats = Notice.count_by_month(Notice.shared, months: @months)
    @photo_stats = Notice.count_by_month(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), months: @months)
  end

  def faq
  end

  def privacy
  end
end
