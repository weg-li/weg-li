class AddDistrictToNotice < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :phone, :string
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float

    add_column :notices, :district, :string, null: false, default: 'hamburg'

    reversible do |dir|
      dir.up do
        execute 'UPDATE notices SET district = users.district FROM users WHERE user_id = users.id'
      end
    end
  end
end
