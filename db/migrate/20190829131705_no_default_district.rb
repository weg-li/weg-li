class NoDefaultDistrict < ActiveRecord::Migration[5.2]
  def change
    change_column :notices, :district, :string, null: true, default: nil
  end
end
