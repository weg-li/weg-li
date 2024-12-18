class AddFalsepositivesToBrands < ActiveRecord::Migration[7.1]
  def change
    change_table :brands do |t|
      t.string :falsepositives, default: [], array: true, null: false
    end
  end
end
