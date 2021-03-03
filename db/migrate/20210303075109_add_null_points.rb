class AddNullPoints < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute "UPDATE charges SET points = 0 WHERE points IS NULL"
        change_column :charges, :points, :integer, default: 0
      end
    end
  end
end
