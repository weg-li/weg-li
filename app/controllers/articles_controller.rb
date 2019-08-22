class ArticlesController < ApplicationController
  def index
    @articles = search_scope
    @facets   = Article.facets

    respond_to do |format|
      format.html
      format.rss
    end
  end

  def show
    @article = Article.from_param(params[:id])
    @facets  = Article.facets
  end

  private

  def search_scope
    scope = Article.active.page(params[:page])
    scope = scope.tagged_with(params[:tag]) if params[:tag]
    scope = scope.in_period(params[:period]) if params[:period]
    scope
  end
end
