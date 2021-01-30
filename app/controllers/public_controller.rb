class PublicController < ApplicationController
  def charge
    @notice = Notice.for_public.from_param(params[:token])
    _404 and return if @notice.blank?

    respond_to do |format|
      format.html
      format.json { render json: @notice.as_api_response(:public_beta) }
    end
  end

  def winowig
    @notice = Notice.for_public.from_param(params[:token])
    _404 and return if @notice.blank?

    respond_to do |format|
      format.xml
    end
  end

  def profile
    @user = User.for_public.from_param(params[:token])
    _404 and return if @user.blank?

    daily = Notice.since(Time.zone.now.beginning_of_day).group(:user_id).order(count_all: :desc).limit(@limit).count
    weekly = Notice.since(Time.zone.now.beginning_of_week).group(:user_id).order(count_all: :desc).limit(@limit).count
    monthly = Notice.since(Time.zone.now.beginning_of_month).group(:user_id).order(count_all: :desc).limit(@limit).count
    yearly = Notice.since(Time.zone.now.beginning_of_year).group(:user_id).order(count_all: :desc).limit(@limit).count
    alltime = Notice.group(:user_id).order(count_all: :desc).limit(@limit).count

    @positions = [
      ['daily', daily.keys.index(@user.id).to_i, daily[@user.id].to_i, daily.first&.last.to_i],
      ['weekly', weekly.keys.index(@user.id).to_i, weekly[@user.id].to_i, weekly.first&.last.to_i],
      ['monthly', monthly.keys.index(@user.id).to_i, monthly[@user.id].to_i, monthly.first&.last.to_i],
      ['yearly', yearly.keys.index(@user.id).to_i, yearly[@user.id].to_i, yearly.first&.last.to_i],
      ['alltime', alltime.keys.index(@user.id).to_i, alltime[@user.id].to_i, alltime.first&.last.to_i],
    ]
  end
end
