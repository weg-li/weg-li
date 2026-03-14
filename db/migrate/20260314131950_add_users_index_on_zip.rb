class AddUsersIndexOnZip < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :zip
    add_index :notices, [:status, :created_at]
  end
end
