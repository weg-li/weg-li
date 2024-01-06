class AddSentAtToNotices < ActiveRecord::Migration[6.1]
  def change
    add_column :notices, :sent_at, :datetime

    reversible do |dir|
      dir.up do
        execute "UPDATE notices SET sent_at = updated_at"
      end
    end
  end
end
