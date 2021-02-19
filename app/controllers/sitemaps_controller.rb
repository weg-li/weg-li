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
      year2019_url,
      year2020_url,
      year2021_url,
      donate_url,
      leaderboard_url,
      violation_url,
      wegeheld_url,
      generator_url,
    ]

    @urls += District.active.pluck(:zip).map { |zip| district_url(zip) }
    @urls += Charge.active.pluck(:tbnr).map { |tbnr| charge_url(tbnr) }
  end
end
