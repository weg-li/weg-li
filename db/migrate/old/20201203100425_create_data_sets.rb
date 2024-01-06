class CreateDataSets < ActiveRecord::Migration[6.1]
  def change
    create_table :data_sets do |t|
      t.references :setable, polymorphic: true
      t.references :keyable, polymorphic: true
      t.json :data
      t.integer :kind, default: 0, nil: false
      t.timestamps
    end
    reversible do |dir|
      dir.up do
        remove_column :notices, :data
      end
    end
  end
end
