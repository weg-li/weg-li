class CreatePlates < ActiveRecord::Migration[7.2]
  def change
    create_table :plates do |t|
      t.string :name
      t.string :prefix, index: { unique: true }
      t.string :zips, default: [], array: true, null: false

      t.timestamps
    end
  end
end
