class AddIncompleteToNotice < ActiveRecord::Migration[5.2]
  def change
    add_column :notices, :incomplete, :boolean, default: false, null: false
  end
end
