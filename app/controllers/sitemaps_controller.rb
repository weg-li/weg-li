class SitemapsController < ApplicationController
  def show
    @urls = [
      root_url,
      faq_url,
      map_url,
      stats_url,
      districts_url,
      privacy_url,
      faq_url,
      year2019_url,
      year2020_url,
    ]

    respond_to do |format|
      format.xml { render xml: @urls }
    end
  end
end
