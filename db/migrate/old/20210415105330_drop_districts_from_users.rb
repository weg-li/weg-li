class DropDistrictsFromUsers < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        remove_column :users, :district
      end
    end
  end
end
