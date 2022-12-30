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
      exports_url,
      features_url,
      privacy_url,
      imprint_url,
      faq_url,
      year_url,
      donate_url,
      leaderboard_url,
      violation_url,
      wegeheld_url,
      generator_url,
      api_url
    ]

    District.active.in_batches do |districts|
      @urls += districts.map { |district| district_url(district) }
    end
    Charge.active.in_batches do |charges|
      @urls += charges.map { |charge| charge_url(charge) }
    end
  end
end
