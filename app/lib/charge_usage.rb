# frozen_string_literal: true

class ChargeUsage
  CACHE_KEY = "api/charges/usage/v1"
  CACHE_TTL = 1.hour

  def self.global
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL, race_condition_ttl: 1.minute) do
      counts = Notice.shared.where(tbnr: Charge.active.select(:tbnr)).group(:tbnr).count
      charges = Charge.active.distinct.pluck(:tbnr).map { |tbnr| { tbnr:, count: counts.fetch(tbnr, 0) } }
      {
        scope: "shared_notices",
        period: "all_time",
        generated_at: Time.current,
        charges: charges.sort_by { |charge| [-charge[:count], charge[:tbnr]] },
      }
    end
  end

  def self.for_user(user)
    rows = user.notices.shared.reorder(nil).where.not(tbnr: [nil, ""]).group(:tbnr).pluck(
      :tbnr,
      Arel.sql("COUNT(*)"),
      Arel.sql("MAX(COALESCE(sent_at, created_at))"),
    )
    {
      scope: "shared_notices",
      period: "all_time",
      charges: rows.sort_by(&:first).map { |tbnr, count, last_used_at| { tbnr:, count:, last_used_at: } },
    }
  end
end
