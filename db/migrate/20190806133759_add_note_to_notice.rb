class AddNoteToNotice < ActiveRecord::Migration[5.2]
  def change
    add_column :notices, :note, :string

    reversible do |dir|
      dir.up do
        remove_column(:notices, :question) if column_exists?(:notices, :question)
        remove_column(:users, :stripe_customer_token) if column_exists?(:users, :stripe_customer_token)
      end
    end
  end
end
