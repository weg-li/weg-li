class AddAnalyzerToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :analyzer, :integer, default: 0, null: false
  end
end
