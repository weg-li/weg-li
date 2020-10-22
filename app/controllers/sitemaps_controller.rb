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
      yearly_url(year: 2019),
      yearly_url(year: 2020),
    ]

    respond_to do |format|
      format.xml { render xml: @urls }
    end
  end
end
