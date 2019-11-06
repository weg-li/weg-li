class AddStatusToBulkUpload < ActiveRecord::Migration[6.0]
  def change
    add_column(:bulk_uploads, :status, :integer, default: 0, index: true)
  end
end
