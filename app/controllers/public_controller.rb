class PublicController < ApplicationController
  def charge
    @notice = Notice.find_by_token!(params[:token])
  end

  def profile
    @user = User.find_by_token!(params[:token])
  end
end
