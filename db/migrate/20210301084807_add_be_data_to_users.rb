class AddBeDataToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :project_access_token, :string
    add_column :users, :project_user_id, :string
  end
end
