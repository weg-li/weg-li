class AddZipIndex < ActiveRecord::Migration[6.0]
  def change
    add_index(:notices, :zip)
  end
end
