class AddValidationDateToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :validation_date, :timestamp
  end
end
