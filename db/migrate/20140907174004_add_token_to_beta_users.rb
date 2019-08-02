class AddTokenToBetaUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :beta_users, :token, :string
  end
end
