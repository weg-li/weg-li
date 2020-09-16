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

    @notices = Notice.shared.since(@since.days.ago).joins(:district).where(districts: {name: @district})
    @active = @notices.map(&:user_id).uniq.size
    @default_district = District.active.find_by(name: @district) || District.active.first
  end

  def stats
    @weeks = (params[:since] || 12).to_i

    @user_counts = User.count_over(User.active, weeks: @weeks)
    @user_sums = User.sum_over(User.active, weeks: @weeks)
    @active_user_counts = User.count_over(User.active.joins(:notices), weeks: @weeks)
    @active_user_sums = User.sum_over(User.active.joins(:notices), weeks: @weeks)
    @notice_counts = Notice.count_over(Notice.shared, weeks: @weeks)
    @notice_sums = Notice.sum_over(Notice.shared, weeks: @weeks)
    @photo_counts = Notice.count_over(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), weeks: @weeks)
    @photo_sums = Notice.sum_over(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), weeks: @weeks)
    @daily_notice_counts = Notice.count_over(Notice.shared, weeks: @weeks, interval: '1 day', beginning: Date.today.beginning_of_day, ending: Date.today.end_of_day)
    @daily_notice_sums = Notice.sum_over(Notice.shared, weeks: @weeks, interval: '1 day', beginning: Date.today.beginning_of_day, ending: Date.today.end_of_day)
  end

  def year2019
    @limit = (params[:limit] || 5).to_i

    notices = Notice.shared.where(date: ((Time.zone.now - 1.year).beginning_of_year..(Time.zone.now - 1.year).end_of_year))
    @count = notices.count
    @active = notices.pluck(:user_id).uniq.size

    @grouped_cities = notices.select('count(city) as city_count, city').group(:city).order('city_count DESC').limit(@limit)
    @grouped_zips = notices.select('count(zip) as zip_count, zip').group(:zip).order('zip_count DESC').limit(@limit)
    @grouped_charges = notices.select('count(charge) as charge_count, charge').group(:charge).order('charge_count DESC').limit(@limit)
    @grouped_brands = notices.select('count(brand) as brand_count, brand').where("brand != ''").group(:brand).order('brand_count DESC').limit(@limit)
  end

  def year2020
    @limit = (params[:limit] || 5).to_i

    notices = Notice.shared.where(date: (Time.zone.now.beginning_of_year..Time.zone.now.end_of_year))
    @count = notices.count
    @active = notices.pluck(:user_id).uniq.size

    @grouped_cities = notices.select('count(city) as city_count, city').group(:city).order('city_count DESC').limit(@limit)
    @grouped_zips = notices.select('count(zip) as zip_count, zip').group(:zip).order('zip_count DESC').limit(@limit)
    @grouped_charges = notices.select('count(charge) as charge_count, charge').group(:charge).order('charge_count DESC').limit(@limit)
    @grouped_brands = notices.select('count(brand) as brand_count, brand').where("brand != ''").group(:brand).order('brand_count DESC').limit(@limit)
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

    @year2019_leaders = Notice.where(date: ((Time.zone.now - 1.year).beginning_of_year..(Time.zone.now - 1.year).end_of_year)).shared.group(:user_id).order(count_all: :desc).limit(@limit).count
    @year2019_leaders.transform_keys! { |user_id| User.find(user_id) }
  end
end
