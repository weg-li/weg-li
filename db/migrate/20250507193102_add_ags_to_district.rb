class AddAgsToDistrict < ActiveRecord::Migration[7.2]
  def change
    add_column :districts, :ags, :string, null: true
  end
end
