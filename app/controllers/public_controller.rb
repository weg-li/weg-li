class PublicController < ApplicationController
  def charge
    @notice = Notice.for_public.from_param(params[:token])
    _404 and return if @notice.blank?

    respond_to do |format|
      format.html
      format.json { render json: @notice.as_api_response(:public_beta) }
    end
  end

  def dresden
    @notice = Notice.for_public.from_param(params[:token])
    _404 and return if @notice.blank?

    respond_to do |format|
      format.xml
    end
  end

  def profile
    @user = User.for_public.from_param(params[:token])
    _404 and return if @user.blank?

    @notices = @user.notices.shared
  end
end
