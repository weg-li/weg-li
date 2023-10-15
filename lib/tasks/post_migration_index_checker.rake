# frozen_string_literal: true

Rake::Task["db:migrate"].enhance do
  tables = ActiveRecord::Base.connection.tables
  all_foreign_keys =
    yolo = tables
             .flat_map do |table_name|
      ActiveRecord::Base
        .connection
        .columns(table_name)
        .map { |c| [table_name, c.name].join(".") }
    end

  yolo.select { |c| c.ends_with?("_id") }

  indexed_columns =
    tables
      .map do |table_name|
        ActiveRecord::Base
          .connection
          .indexes(table_name)
          .map { |index| index.columns.map { |c| [table_name, c].join(".") } }
      end
      .flatten

  unindexed_foreign_keys = (all_foreign_keys - indexed_columns)

  if unindexed_foreign_keys.any?
    warn "WARNING: The following foreign key columns don't have an index, which can hurt performance: #{unindexed_foreign_keys.join(', ')}"
  end
end
