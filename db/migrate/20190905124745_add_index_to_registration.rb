class AddIndexToRegistration < ActiveRecord::Migration[5.2]
  def change
    add_index :notices, :registration
  end
end
