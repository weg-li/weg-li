class HomeController < ApplicationController
  def index
  end

  def map
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    @district = params[:district] || 'Hamburg'

    @notices = Notice.shared.since(@since.days.ago).where(district: @district.downcase)
    @active = @notices.map(&:user_id).uniq.size
  end

  def faq
  end

  def privacy
  end
end
