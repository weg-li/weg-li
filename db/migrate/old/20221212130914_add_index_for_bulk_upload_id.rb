class AddIndexForBulkUploadId < ActiveRecord::Migration[7.0]
  def change
    add_index :notices, :bulk_upload_id
  end
end
