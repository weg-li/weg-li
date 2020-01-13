class ZipUnique < ActiveRecord::Migration[6.0]
  def change
    remove_index(:districts, :zip)
    add_index(:districts, :zip, unique: true)
  end
end
