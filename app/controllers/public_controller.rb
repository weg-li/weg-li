class PublicController < ApplicationController
  def charge
    @notice = Notice.for_public.find_by(token: params[:token])
    _404 and return if @notice.blank?

    respond_to do |format|
      format.html
      format.json { render json: @notice.as_api_response(:public_beta) }
    end
  end

  def profile
    @user = User.for_public.find_by(token: params[:token])
    _404 and return if @user.blank?

    @notices = @user.notices.shared
  end
end
