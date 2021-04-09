class AddIndexToAttachment < ActiveRecord::Migration[6.1]
  def change
    add_index(:active_storage_attachments, :record_type)
  end
end
