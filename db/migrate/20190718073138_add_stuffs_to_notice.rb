class AddStuffsToNotice < ActiveRecord::Migration[5.2]
  def change
    add_column :notices, :flags, :integer, default: 0, null: false
    add_column :notices, :date, :datetime
    add_column :notices, :charge, :string
    add_column :notices, :kind, :string
    add_column :notices, :brand, :string
    add_column :notices, :model, :string
    add_column :notices, :color, :string
    add_column :notices, :registration, :string
    add_column :notices, :location, :string
    add_column :notices, :latitude, :float
    add_column :notices, :longitude, :float
  end
end
