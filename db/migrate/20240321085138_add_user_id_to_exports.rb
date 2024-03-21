class AddUserIdToExports < ActiveRecord::Migration[7.1]
  def change
    change_table :exports do |t|
      t.references :user, foreign_key: true, null: true, index: true
      t.integer :file_extension, default: 0, null: false
    end
  end
end
