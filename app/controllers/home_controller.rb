class HomeController < ApplicationController
  def index
  end

  def map
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    @district = District.by_name(params[:district] || current_user&.district_name || 'hamburg')

    @notices = Notice.shared.for_public.since(@since.days.ago).where(user_id: User.for_public.where(district: @district.name).pluck(:id))
    @active = @notices.map(&:user_id).uniq.size
    @total = User.count
    @count = User.group(:district).count
  end

  def faq
  end

  def privacy
  end
end
