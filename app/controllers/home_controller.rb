class HomeController < ApplicationController
  def index
    @goals = {
      week: Notice.shared.since(Time.zone.now.beginning_of_week).count,
      month: Notice.shared.since(Time.zone.now.beginning_of_month).count,
      year: Notice.shared.since(Time.zone.now.beginning_of_year).count,
    }
    @statistics = Notice.statistics
  end

  def map
    @limit = (params[:limit] || 5).to_i
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    @district = params[:district] || current_user&.city || 'Hamburg'

    @notices = Notice.includes(:user).shared.since(@since.days.ago).joins(:district).where(districts: {name: @district})
    @active = @notices.map(&:user_id).uniq.size
    @default_district = District.active.find_by(name: @district) || District.active.first
  end

  def stats
    @weeks = (params[:since] || 8).to_i

    @user_counts = User.count_over(User.active, weeks: @weeks)
    @user_sums = User.sum_over(User.active, weeks: @weeks)
    @active_user_counts = User.count_over(User.active.joins(:notices), weeks: @weeks)
    @active_user_sums = User.sum_over(User.active.joins(:notices), weeks: @weeks)
    @notice_counts = Notice.count_over(Notice.shared, weeks: @weeks)
    @notice_sums = Notice.sum_over(Notice.shared, weeks: @weeks)
    @photo_counts = Notice.count_over(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), weeks: @weeks)
    @photo_sums = Notice.sum_over(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), weeks: @weeks)
    @daily_notice_counts = Notice.count_over(Notice.shared, weeks: @weeks / 2, interval: '1 day', beginning: Date.today.beginning_of_day, ending: Date.today.end_of_day)
    @daily_notice_sums = Notice.sum_over(Notice.shared, weeks: @weeks / 2, interval: '1 day', beginning: Date.today.beginning_of_day, ending: Date.today.end_of_day)
  end

  def year2019
    limit = (params[:limit] || 5).to_i
    @statistics = Notice.yearly_statistics(2019, limit)
  end

  def year2020
    limit = (params[:limit] || 5).to_i
    @statistics = Notice.yearly_statistics(2020, limit)
  end

  def leaderboard
    @limit = (params[:limit] || 5).to_i

    @weekly_leaders = Notice.since(Time.zone.now.beginning_of_week).shared.group(:user_id).order(count_all: :desc).limit(@limit).count
    @weekly_leaders.transform_keys! { |user_id| User.find(user_id) }

    @monthly_leaders = Notice.since(Time.zone.now.beginning_of_month).shared.group(:user_id).order(count_all: :desc).limit(@limit).count
    @monthly_leaders.transform_keys! { |user_id| User.find(user_id) }

    @yearly_leaders = Notice.since(Time.zone.now.beginning_of_year).shared.group(:user_id).order(count_all: :desc).limit(@limit).count
    @yearly_leaders.transform_keys! { |user_id| User.find(user_id) }

    @total_leaders = Notice.shared.group(:user_id).order(count_all: :desc).limit(@limit).count
    @total_leaders.transform_keys! { |user_id| User.find(user_id) }

    @year2019_leaders = Notice.where(date: ('01.08.2019'.to_date)..('01.08.2019'.to_date.end_of_year)).shared.group(:user_id).order(count_all: :desc).limit(@limit).count
    @year2019_leaders.transform_keys! { |user_id| User.find(user_id) }
  end

  def generator
    if params[:stadtreinigung].present?
      data = ParkGenerator.new.generate(params[:stadtreinigung_name])

      send_data data, filename: "Stadtreinigung #{params[:stadtreinigung_name]}.pdf"
    elsif params[:parkraummanagement].present?
      data = ViolationGenerator.new.generate(params[:parkraummanagement_name])

      send_data data, filename: "Parkraum-Management #{params[:parkraummanagement_name]}.pdf"
    end
  end
end
