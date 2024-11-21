class AddSigns < ActiveRecord::Migration[7.1]
  def change
    create_table :signs do |t|
      t.string :number, index: { unique: true }
      t.string :description

      t.timestamps
    end
  end
end
