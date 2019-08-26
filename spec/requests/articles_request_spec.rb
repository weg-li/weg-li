require 'spec_helper'

describe "blog", type: :request  do
  before do
    @article = Fabricate(:article)
  end

  context "articles#index" do
    it "loads all active articles and article-facets" do
      get articles_path

      expect(response).to be_successful
      assert_select 'h2', @article.title
      assert_select 'a', @article.tags.first
    end

    it "loads a feed in rss" do
      get articles_path(format: :rss)

      expect(response).to be_successful
      expect(response.content_type).to eql(Mime[:rss].to_s)
    end
  end

  context "articles#show" do
    it "loads article and article-facets" do
      get article_path(@article)

      expect(response).to be_successful
      assert_select 'h2', @article.title
      assert_select 'a', @article.tags.first
    end
  end
end
