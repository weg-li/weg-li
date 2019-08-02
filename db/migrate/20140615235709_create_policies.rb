class CreatePolicies < ActiveRecord::Migration[4.2]
  def change
    create_table :policies do |t|
      t.string :name
      t.json :setting
      t.references :notice

      t.timestamps
    end
  end
end
