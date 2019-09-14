require 'spec_helper'

describe Article do
  let(:article) { Fabricate.build(:article) }

  context "validation" do
    it "is valid" do
      expect(article).to be_valid
    end
  end

  context "finder" do
    before do
      @article = Fabricate(:article)
    end

    it "has a friendly url" do
      article = Article.from_param(@article.to_param)
      expect(article).to eql(@article)
    end

    it "finds articles by tag" do
      articles = Article.tagged_with(@article.tags.first)
      expect(articles.to_a).to eql([@article])
    end

    it "finds articles in period" do
      @article.update! published_at: 2.weeks.ago
      articles = Article.in_period('this month')
      expect(articles.to_a).to eql([@article])
    end
  end

  context "facets" do
    it "has a friendly url" do
      Fabricate(:article, tags: ['one', 'two', 'three'])
      Fabricate(:article, tags: ['one', 'two'], published_at: 2.weeks.ago)
      Fabricate(:article, tags: ['one'], published_at: 2.month.ago)
      facets = Article.facets
      expect(facets[:tags]).to eql('one' => 3, 'two' => 2, 'three' => 1)
      expect(facets[:dates]).to eql('this year' => 3, 'this month' => 2, 'this week' => 1)
    end
  end
end
