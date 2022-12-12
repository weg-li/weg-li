class AddIndexToAuthrorization < ActiveRecord::Migration[7.0]
  def change
    add_index :authorizations, :user_id
  end
end
