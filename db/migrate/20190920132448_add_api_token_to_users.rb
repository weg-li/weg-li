class AddApiTokenToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :api_token, :string
  end
end
