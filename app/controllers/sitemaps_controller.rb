# frozen_string_literal: true

class SitemapsController < ApplicationController
  def show
    @urls = [
      root_url,
      faq_url,
      map_url,
      stats_url,
      districts_url,
      charges_url,
      brands_url,
      exports_url,
      features_url,
      privacy_url,
      imprint_url,
      integrations_url,
      faq_url,
      year_url,
      donate_url,
      leaderboard_url,
      violation_url,
      wegeheld_url,
      generator_url,
      api_url,
    ]

    District.active.in_batches do |items|
      @urls += items.map { |item| district_url(item) }
    end
    Charge.active.in_batches do |items|
      @urls += items.map { |item| charge_url(item) }
    end
    Brand.active.in_batches do |items|
      @urls += items.map { |item| brand_url(item) }
    end
    Sign.in_batches do |items|
      @urls += items.map { |item| sign_url(item) }
    end
  end
end
