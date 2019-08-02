class AddStatusToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :status, :integer, default: 0
  end
end
