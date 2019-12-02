class SitemapsController < ApplicationController
  def show
    @urls = [
      root_url,
      faq_url,
      map_url,
    ]


    respond_to do |format|
      format.xml { render xml: @urls }
    end
  end
end
