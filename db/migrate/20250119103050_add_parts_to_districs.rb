class AddPartsToDistrics < ActiveRecord::Migration[7.2]
  def change
    change_table :districts do |t|
      t.string :parts, default: [], array: true, null: false
    end
  end
end
