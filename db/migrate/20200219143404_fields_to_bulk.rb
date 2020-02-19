class FieldsToBulk < ActiveRecord::Migration[6.0]
  def change
    add_column :bulk_uploads, :error_message, :string
    add_column :bulk_uploads, :shared_album_url, :string
  end
end
