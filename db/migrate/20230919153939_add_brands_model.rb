class AddBrandsModel < ActiveRecord::Migration[7.0]
  def change
    create_table :brands do |t|

      t.string :name, index: true, nil: false
      t.string :token, index: true, nil: false
      t.integer :kind, default: 0, nil: false
      t.string :aliases, default: [], array: true
      t.string :models, default: [], array: true
      t.timestamps
    end
  end
end
