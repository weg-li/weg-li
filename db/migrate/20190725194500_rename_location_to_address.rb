class RenameLocationToAddress < ActiveRecord::Migration[5.2]
  def change
    rename_column :notices, :location, :address
  end
end
