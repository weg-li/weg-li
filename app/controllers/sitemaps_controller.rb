class SitemapsController < ApplicationController
  def show
    @urls = [
      root_url,
      faq_url,
      map_url,
      blog_url,
    ] + Article.active.map { |article| article_url(article) }


    respond_to do |format|
      format.xml { render xml: @urls }
    end
  end
end
