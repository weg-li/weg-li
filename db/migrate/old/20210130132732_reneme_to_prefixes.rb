class RenemeToPrefixes < ActiveRecord::Migration[6.1]
  def change
    rename_column :districts, :prefix, :prefixes
  end
end
