# frozen_string_literal: true

module Statisticable
  extend ActiveSupport::Concern

  class_methods do
    def count_over(included_scope = nil, weeks: 52, interval: '1 week')
      included_scope ||= self
      sql = "SELECT d, count(#{included_scope.table_name}.id) AS c
             FROM generate_series('#{Date.today.beginning_of_week}'::timestamp - interval '#{weeks} weeks', '#{Date.today.end_of_week}'::timestamp, '#{interval}') d
             LEFT JOIN #{included_scope.table_name} ON #{included_scope.table_name}.created_at <= d AND (#{included_scope.table_name}.id IN(#{included_scope.select(:id).to_sql}))
             GROUP BY 1 ORDER BY d;"

      result = find_by_sql(sql).pluck(:d, :c)
      Hash[result]
    end

    def sum_over(included_scope = nil, weeks: 52, interval: '1 week')
      included_scope ||= self
      sql = "SELECT d, count(#{included_scope.table_name}.id) AS c
             FROM generate_series('#{Date.today.beginning_of_week}'::timestamp - interval '#{weeks} weeks', '#{Date.today.end_of_week}'::timestamp, '#{interval}') d
             LEFT JOIN #{included_scope.table_name} ON #{included_scope.table_name}.created_at BETWEEN d AND d + interval '#{interval}'  AND (#{included_scope.table_name}.id IN(#{included_scope.select(:id).to_sql}))
             GROUP BY 1 ORDER BY d;"

      result = find_by_sql(sql).pluck(:d, :c)
      Hash[result]
    end
  end
end
