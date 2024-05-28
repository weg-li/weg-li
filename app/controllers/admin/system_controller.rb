module Admin
  class SystemController < Admin::ApplicationController
    def blocklist_ip
      Rack::Attack.blocklist_ip(params[:ip])

      redirect_to admin_system_index_path, notice: "'#{params[:ip]}' wurde geblockt"
    end

    def index
      table_size_sql = <<-SQL
        SELECT
          table_name,
          pg_table_size('"' || table_name || '"') AS table_size,
          pg_indexes_size('"' || table_name || '"') AS indexes_size,
          pg_total_relation_size('"' || table_name || '"') AS total_size
        FROM information_schema.tables
        WHERE table_schema = 'public'
        ORDER BY total_size DESC
      SQL

      @table_size = ActiveRecord::Base.connection.execute(table_size_sql)

      query_cache_sql = <<-SQL
        SELECT
          sum(heap_blks_read) as heap_read,
          sum(heap_blks_hit)  as heap_hit,
          (sum(heap_blks_hit) - sum(heap_blks_read)) / sum(heap_blks_hit) as ratio
        FROM
          pg_statio_user_tables
      SQL

      @query_cache = ActiveRecord::Base.connection.execute(query_cache_sql).first

      index_cache_sql = <<-SQL
        SELECT
          sum(idx_blks_read) as idx_read,
          sum(idx_blks_hit)  as idx_hit,
          (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit) as ratio
        FROM
          pg_statio_user_indexes
      SQL

      @index_cache = ActiveRecord::Base.connection.execute(index_cache_sql).first

      index_usage_sql = <<-SQL
        SELECT
          relname,
          CASE WHEN (seq_scan + idx_scan) > 0  THEN 100 * idx_scan / (seq_scan + idx_scan) ELSE 0 END percent_of_times_index_used,
          n_live_tup rows_in_table
        FROM
          pg_stat_user_tables
        ORDER BY
          n_live_tup DESC
      SQL

      @index_usage = ActiveRecord::Base.connection.execute(index_usage_sql)

      @cache_stats = Rails.cache.try(:stats)

      @api_stats = Counter.stats

      @env =
        ENV
          .map do |key, value|
            if /KEY|SECRET|PASSWORD|TOKEN|CREDENTIALS|URL|SECRET|DATABASE/.match?(
                 key
               )
              [key, "[FILTERED]"]
            else
              [key, value]
            end
          end
          .sort
      @env << ["RAILS_VERSION", Rails.version]
      @env << ["RUBY_VERSION", RUBY_VERSION]
    end
  end
end
