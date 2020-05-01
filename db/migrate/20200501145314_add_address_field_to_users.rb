class AddAddressFieldToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :appendix, :string
  end
end
