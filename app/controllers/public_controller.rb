# frozen_string_literal: true

class PublicController < ApplicationController
  def charge
    @notice = Notice.for_public.from_param(params[:token])
    _404 and return if @notice.blank?

    respond_to do |format|
      format.html
      format.json { render json: @notice.as_api_response(:public_beta) }
    end
  end

  def profile
    @user = User.for_public.from_param(params[:token])
    _404 and return if @user.blank?

    @positions = @user.leaderboard_positions
  end

  def archive
    _404 and return if user.blank?
    _404 and return if notice.blank?

    template = notice.district.config
    generator = ZipGenerator.new(notice, template)
    file = generator.generate
    send_data file.read, filename: generator.filename
  end

  private

  # REM: (PS) uses memoization pattern bc the xml builder cant take member vars no more
  helper_method :user, :notice

  def user
    @user ||= User.from_param(params[:user_token])
  end

  def notice
    @notice ||= user.notices.for_public.where("start_date > ?", 4.weeks.ago).from_param(params[:notice_token])
  end
end
