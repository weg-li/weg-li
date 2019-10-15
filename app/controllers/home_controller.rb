class HomeController < ApplicationController
  def index
  end

  def map
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    @district = params[:district] || current_user&.city || 'Hamburg'

    @notices = Notice.shared.since(@since.days.ago).joins(:district).where(districts: {name: @district})
    @active = @notices.map(&:user_id).uniq.size
    @default_district = District.find_by(name: @district) || District.first
  end

  def faq
  end

  def privacy
  end
end
