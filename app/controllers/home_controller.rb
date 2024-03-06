# frozen_string_literal: true

class HomeController < ApplicationController
  helper_method :goals, :statistics, :yearly_statistics, :count_sum

  def index; end

  def map
    @limit = (params[:limit] || 5).to_i
    @since = (params[:since] || "7").to_i
    @display = params[:display] || "cluster"

    @district = params[:district] || current_user&.city
    @default_district =
      District.active.find_by(name: @district) ||
      District.active.find_by(name: "Hamburg") || District.active.first
    @district = @default_district.name

    @notices =
      Notice
        .includes(:user)
        .shared
        .since(@since.days.ago)
        .joins(:district)
        .where(districts: { name: @default_district.name })
    @active = @notices.map(&:user_id).uniq.size
  end

  def stats
    @since = (params[:since] || 4).to_i
    @display = params[:display] || "user"
    @interval = params[:interval] || "1 week"
  end

  def year
    @limit = (params[:limit] || 5).to_i
    @years = years
    @year = @years.include?(params[:year].to_i) ? params[:year].to_i : @years.max
  end

  def leaderboard
    @limit = (params[:limit] || 5).to_i
  end

  helper_method :weekly_leaders, :monthly_leaders, :yearly_leaders, :total_leaders, :year_leaders, :leaderboard_users

  def year_leaders
    @year_leaders = years[1..].to_h { |year| [year, leaders_count(year, @limit)] }
  end

  def leaderboard_users
    user_ids = weekly_leaders.keys + monthly_leaders.keys + yearly_leaders.keys + total_leaders.keys + year_leaders.values.flat_map(&:keys)
    @users = User.find(user_ids)
  end

  def weekly_leaders
    @weekly_leaders = leaders(Time.zone.now.beginning_of_week, @limit)
  end

  def monthly_leaders
    @monthly_leaders = leaders(Time.zone.now.beginning_of_month, @limit)
  end

  def yearly_leaders
    @yearly_leaders = leaders(Time.zone.now.beginning_of_year, @limit)
  end

  def total_leaders
    @total_leaders = leaders(10.years.ago, @limit)
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

  def years
    (2019..Time.zone.now.year).to_a.reverse
  end

  def leaders(since, limit)
    Notice
      .shared
      .since(since)
      .group(:user_id)
      .order(count_all: :desc)
      .limit(limit)
      .count
  end

  def leaders_count(year, limit)
    Notice.where(start_date: ("01.01.#{year}".to_date.beginning_of_year)..("31.12.#{year}".to_date.end_of_year))
      .shared
      .group(:user_id)
      .order(count_all: :desc)
      .limit(limit)
      .count
  end

  def count_sum
    @count_sum ||=
      case @display
      when "user"
        {
          counts:
            User.count_over(User.active, weeks: @since, interval: @interval),
          sums: User.sum_over(User.active, weeks: @since, interval: @interval),
        }
      when "active"
        {
          counts:
            User.count_over(
              User.active.joins(:notices),
              weeks: @since,
              interval: @interval,
            ),
          sums:
            User.sum_over(
              User.active.joins(:notices),
              weeks: @since,
              interval: @interval,
            ),
        }
      when "notice"
        {
          counts:
            Notice.count_over(
              Notice.shared,
              weeks: @since,
              interval: @interval,
            ),
          sums:
            Notice.sum_over(Notice.shared, weeks: @since, interval: @interval),
        }
      when "photo"
        {
          counts:
            Notice.count_over(
              ActiveStorage::Attachment.where(
                record_type: "Notice",
                name: "photos",
              ),
              weeks: @since,
              interval: @interval,
            ),
          sums:
            Notice.sum_over(
              ActiveStorage::Attachment.where(
                record_type: "Notice",
                name: "photos",
              ),
              weeks: @since,
              interval: @interval,
            ),
        }
      else
        { counts: {}, sums: {} }
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
