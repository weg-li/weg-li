# frozen_string_literal: true

class Homepage < ApplicationRecord
  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  def self.populated?
    Scenic.database.populated?(table_name)
  end

  def self.statistics
    first.attributes.symbolize_keys
  end
end
