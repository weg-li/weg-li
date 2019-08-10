class HomeController < ApplicationController
  def index
  end

  def map
    @district = District.by_name(params[:district] || 'hamburg')

    @notices = Notice.shared.for_public.where(user_id: User.for_public.where(district: @district.name).pluck(:id))
    @active = @notices.map(&:user_id).uniq.size
    @total = User.count
    @count = User.group(:district).count
  end

  def faq
  end

  def privacy
  end
end
