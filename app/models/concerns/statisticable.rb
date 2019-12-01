# frozen_string_literal: true

module Statisticable
  extend ActiveSupport::Concern

  class_methods do
    def count_by_month(included_scope = nil, months: 12)
      included_scope ||= self
      sql = "SELECT d, count(#{table_name}.id) AS c
             FROM generate_series( '#{Time.now.utc}'::timestamp - interval '#{months} months', '#{Time.now.utc}'::timestamp, '1 month') d
             LEFT JOIN #{table_name} ON #{table_name}.created_at <= d
               AND (#{table_name}.id IN(#{included_scope.select(:id).to_sql}))
             GROUP BY 1 ORDER BY d;"

      result = find_by_sql(sql).pluck(:d, :c)
      Hash[result]
    end
  end
end
