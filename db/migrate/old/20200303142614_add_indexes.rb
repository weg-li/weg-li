class AddIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index(:users, :email, unique: true)
    add_index(:users, :token, unique: true)
    add_index(:users, :api_token, unique: true)
  end
end
