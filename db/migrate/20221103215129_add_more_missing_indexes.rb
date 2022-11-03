class AddMoreMissingIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :notices, :date
  end
end
