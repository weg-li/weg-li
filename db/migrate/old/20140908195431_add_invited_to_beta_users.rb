class AddInvitedToBetaUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :beta_users, :invited, :timestamp
  end
end
