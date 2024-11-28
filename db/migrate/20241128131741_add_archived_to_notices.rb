class AddArchivedToNotices < ActiveRecord::Migration[7.1]
  def change
    change_table :notices do |t|
      t.boolean :archived, default: false, null: false, index: true
    end
  end
end
