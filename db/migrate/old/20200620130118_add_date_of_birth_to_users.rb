class AddDateOfBirthToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :date_of_birth, :date
  end
end
