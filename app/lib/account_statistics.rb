# frozen_string_literal: true

class AccountStatistics
  def initialize(user)
    @user = user
  end

  def to_h
    {
      name: @user.name,
      nickname: @user.nickname,
      statistics: notice_counts,
      charge_usage: ChargeUsage.for_user(@user),
    }
  end

  private

  def notice_counts
    statistics = { notices: 0, open: 0, analyzing: 0, disabled: 0, shared: 0, incomplete: 0, archived: 0 }
    @user.notices.reorder(nil).group(:status, :incomplete, :archived).count.each do |(status, incomplete, archived), count|
      statistics[:notices] += count
      statistics[status.to_sym] += count if Notice.status.key?(status)
      statistics[:incomplete] += count if incomplete
      statistics[:archived] += count if archived
    end
    statistics
  end
end
