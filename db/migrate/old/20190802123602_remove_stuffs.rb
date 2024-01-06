class RemoveStuffs < ActiveRecord::Migration[5.2]
  def change
    drop_table :beta_users, if_exists: true
    drop_table :openings, if_exists: true
    drop_table :policies, if_exists: true
  end
end
