class PublicController < ApplicationController
  def charge
    @notice = Notice.for_public.find_by_token!(params[:token])
  end

  def profile
    @user = User.for_public.find_by_token!(params[:token])
    @notices = @user.notices.shared
  end
end
