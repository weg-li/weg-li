class CreateExports < ActiveRecord::Migration[6.0]
  def change
    create_table :exports do |t|
      t.integer :export_type, default: 0, null: false
      t.integer :interval, null: false

      t.timestamps
    end
  end
end
