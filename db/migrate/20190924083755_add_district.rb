class AddDistrict < ActiveRecord::Migration[6.0]
  def change
    create_table :districts do |t|
      t.string :name, null: false, index: true
      t.string :zip, null: false
      t.string :email, null: false
      t.string :prefix
      t.float :latitude
      t.float :longitude

      t.timestamps

      t.index [ :zip ], unique: true
    end

    reversible do |dir|
      dir.up do
        CSV.parse(File.read('config/data/publicaffairsoffice.csv'), col_sep: ';') do |line|
          execute "INSERT INTO districts (name, zip, email, created_at, updated_at) VALUES ('#{line[0]}', '#{line[1]}', '#{line[2]}', NOW(), NOW())"
        end
      end
    end
  end
end
