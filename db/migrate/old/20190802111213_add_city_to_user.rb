class AddCityToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :district, :string, null: false, default: 'hamburg'
  end
end
