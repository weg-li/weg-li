# frozen_string_literal: true

class HomeController < ApplicationController
  helper_method :goals, :statistics, :yearly_statistics, :count_sum

  def index; end

  def map
    @limit = (params[:limit] || 5).to_i
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'

    @district = params[:district] || current_user&.city
    @default_district = District.active.find_by(name: @district) || District.active.find_by(name: 'Hamburg') || District.active.first
    @district = @default_district.name

    @notices = Notice.includes(:user).shared.since(@since.days.ago).joins(:district).where(districts: { name: @default_district.name })
    @active = @notices.map(&:user_id).uniq.size
  end

  def stats
    @since = (params[:since] || 4).to_i
    @display = params[:display] || 'user'
    @interval = params[:interval] || '1 week'
  end

  def year2019
    @limit = (params[:limit] || 5).to_i
    @yearl = 2019
  end

  def year2020
    @limit = (params[:limit] || 5).to_i
    @yearl = 2020
  end

  def year2021
    @limit = (params[:limit] || 5).to_i
    @yearl = 2021
  end

  def year2022
    @limit = (params[:limit] || 5).to_i
    @yearl = 2022
  end

  def leaderboard
    @limit = (params[:limit] || 5).to_i

    @weekly_leaders = Notice.shared.since(Time.zone.now.beginning_of_week).group(:user_id).order(count_all: :desc).limit(@limit).count
    @monthly_leaders = Notice.shared.since(Time.zone.now.beginning_of_month).group(:user_id).order(count_all: :desc).limit(@limit).count
    @yearly_leaders = Notice.shared.since(Time.zone.now.beginning_of_year).group(:user_id).order(count_all: :desc).limit(@limit).count
    @total_leaders = Notice.shared.group(:user_id).order(count_all: :desc).limit(@limit).count

    @year_leaders = {
      2019 => Notice.where(date: ('01.08.2019'.to_date)..('01.08.2019'.to_date.end_of_year)).shared.group(:user_id).order(count_all: :desc).limit(@limit).count,
      2020 => Notice.where(date: ('01.01.2020'.to_date.beginning_of_year)..('31.12.2020'.to_date.end_of_year)).shared.group(:user_id).order(count_all: :desc).limit(@limit).count,
      2021 => Notice.where(date: ('01.01.2021'.to_date.beginning_of_year)..('31.12.2021'.to_date.end_of_year)).shared.group(:user_id).order(count_all: :desc).limit(@limit).count,
    }

    @users = User.where(id: @weekly_leaders.keys + @monthly_leaders.keys + @yearly_leaders.keys + @total_leaders.keys + @year_leaders.values.flat_map(&:keys))
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

  private

  def count_sum
    @count_sum ||=
      case @display
      when 'user'
        {
          counts: User.count_over(User.active, weeks: @since, interval: @interval),
          sums: User.sum_over(User.active, weeks: @since, interval: @interval),
        }
      when 'active'
        {
          counts: User.count_over(User.active.joins(:notices), weeks: @since, interval: @interval),
          sums: User.sum_over(User.active.joins(:notices), weeks: @since, interval: @interval),
        }
      when 'notice'
        {
          counts: Notice.count_over(Notice.shared, weeks: @since, interval: @interval),
          sums: Notice.sum_over(Notice.shared, weeks: @since, interval: @interval),
        }
      when 'photo'
        {
          counts: Notice.count_over(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), weeks: @since, interval: @interval),
          sums: Notice.sum_over(ActiveStorage::Attachment.where(record_type: 'Notice', name: 'photos'), weeks: @since, interval: @interval),
        }
      else
        {
          counts: {},
          sums: {},
        }
      end
  end

  def yearly_statistics
    @yearly_statistics ||= Notice.yearly_statistics(@year, @limit)
  end

  def goals
    @goals ||= {
      week: Notice.shared.since(Time.zone.now.beginning_of_week).count,
      month: Notice.shared.since(Time.zone.now.beginning_of_month).count,
      year: Notice.shared.since(Time.zone.now.beginning_of_year).count,
    }
  end

  def statistics
    @statistics ||= Notice.statistics
  end
end
