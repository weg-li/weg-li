class AddBulkUpload < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_uploads do |t|
      t.references :user
      t.timestamps
    end

    add_column :notices, :bulk_upload_id, :integer
  end
end
