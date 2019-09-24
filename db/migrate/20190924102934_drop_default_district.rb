class DropDefaultDistrict < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        change_column :users, :district, :string, null: true, default: nil
      end
    end
  end
end
