class AddCreatedAtIndexToNotices < ActiveRecord::Migration[6.1]
  def change
    add_index(:notices, :created_at)
    add_index(:notices, :status)
  end
end
