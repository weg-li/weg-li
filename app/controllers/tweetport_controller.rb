class TweetportController < ApplicationController
  def new
    if params[:tweet_url].present?
      @tweet_url = params[:tweet_url]
      @tweet = Twttr.client.status(@tweet_url, tweet_mode: :extended)
    end
  end
end
