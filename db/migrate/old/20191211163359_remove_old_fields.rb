class RemoveOldFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :notices, :district_legacy
    remove_column :notices, :model
    remove_column :notices, :address

    remove_column :users, :address
    remove_column :users, :time_zone
  end
end
