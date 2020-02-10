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
    @months = 3

    @user_counts = User.count_by_month(User.active, months: @months)
    @user_sums = User.sum_by_month(User.active, months: @months)
    @active_user_counts = User.count_by_month(User.active.joins(:notices), months: @months)
    @active_user_sums = User.sum_by_month(User.active.joins(:notices), months: @months)
    @notice_counts = Notice.count_by_month(Notice.shared, months: @months)
    @notice_sums = Notice.sum_by_month(Notice.shared, months: @months)
    @photo_counts = Notice.count_by_month(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), months: @months)
    @photo_sums = Notice.sum_by_month(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), months: @months)
  end

  def year2019
    notices = Notice.shared.where(date: ((Time.zone.now - 1.year).beginning_of_year..(Time.zone.now - 1.year).end_of_year))
    @count = notices.count
    @active = notices.pluck(:user_id).uniq.size
    @grouped_cities = notices.select('count(city) as city_count, city').group(:city).order('city_count DESC').limit(5)
    @grouped_zips = notices.select('count(zip) as zip_count, zip').group(:zip).order('zip_count DESC').limit(5)
    @grouped_charges = notices.select('count(charge) as charge_count, charge').group(:charge).order('charge_count DESC').limit(5)
    @grouped_brands = notices.select('count(brand) as brand_count, brand').where("brand != ''").group(:brand).order('brand_count DESC').limit(5)
  end

  def year2020
    notices = Notice.shared.where(date: (Time.zone.now.beginning_of_year..Time.zone.now.end_of_year))
    @count = notices.count
    @active = notices.pluck(:user_id).uniq.size
    @grouped_cities = notices.select('count(city) as city_count, city').group(:city).order('city_count DESC').limit(5)
    @grouped_zips = notices.select('count(zip) as zip_count, zip').group(:zip).order('zip_count DESC').limit(5)
    @grouped_charges = notices.select('count(charge) as charge_count, charge').group(:charge).order('charge_count DESC').limit(5)
    @grouped_brands = notices.select('count(brand) as brand_count, brand').where("brand != ''").group(:brand).order('brand_count DESC').limit(5)
  end

  def faq
  end

  def privacy
  end
end
