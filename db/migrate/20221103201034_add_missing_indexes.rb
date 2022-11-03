class AddMissingIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :notices, :user_id
    add_index :users, :access
  end
end
