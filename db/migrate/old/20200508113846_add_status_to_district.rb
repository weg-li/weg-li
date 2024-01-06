class AddStatusToDistrict < ActiveRecord::Migration[6.0]
  def change
    add_column :districts, :status, :integer, default: 0

    add_index :districts, :status
  end
end
