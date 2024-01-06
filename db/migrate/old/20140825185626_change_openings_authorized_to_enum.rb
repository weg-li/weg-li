class ChangeOpeningsAuthorizedToEnum < ActiveRecord::Migration[4.2]
  def change
    add_column :openings, :authorization, :integer, default: 0
    remove_column :openings, :authorized
  end
end
