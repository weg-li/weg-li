class AddStatusToBrand < ActiveRecord::Migration[7.1]
  def change
    change_table :brands do |t|
      t.integer :status, default: 0, null: false
    end
  end
end
