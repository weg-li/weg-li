class AddNotNullToDistrict < ActiveRecord::Migration[7.2]
  def change
    reversible do |dir|
      dir.up do
        District.where(prefixes: nil).update_all(prefixes: [])
        Brand.where(models: nil).update_all(models: [])
        Brand.where(aliases: nil).update_all(aliases: [])
      end
    end
    change_column :districts, :prefixes, :string, default: [], array: true, null: false
    change_column :brands, :models, :string, default: [], array: true, null: false
    change_column :brands, :aliases, :string, default: [], array: true, null: false
  end
end
