class AddLocationToNotices < ActiveRecord::Migration[6.1]
  def change
    add_column :notices, :location, :string
  end
end
