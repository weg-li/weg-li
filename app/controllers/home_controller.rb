class HomeController < ApplicationController
  def index
  end

  def map
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    # TODO search for district
    @district = DistrictLegacy.by_name(params[:district] || current_user&.district_name || 'hamburg') || DistrictLegacy::HAMBURG

    @notices = Notice.shared.since(@since.days.ago).where(district: @district.name)
    @active = @notices.map(&:user_id).uniq.size
    @total = User.count
    @count = User.group(:district).count
  end

  def faq
  end

  def privacy
  end
end
