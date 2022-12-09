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

  def winowig
    @user = User.from_param(params[:user_token])
    _404 and return if @user.blank?

    @notice =
      @user
        .notices
        .for_public
        .where("date > ?", 4.weeks.ago)
        .from_param(params[:notice_token])
    _404 and return if @notice.blank?

    respond_to { |format| format.xml }
  end
end
