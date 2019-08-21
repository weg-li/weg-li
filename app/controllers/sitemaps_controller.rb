class SitemapsController < ApplicationController
  respond_to :xml

  def show
    @urls = [
      root_url,
      faq_url,
      map_url,
      blog_url,
    ] + Article.active.map { |article| article_url(article) }

    respond_with(@urls)
  end
end
