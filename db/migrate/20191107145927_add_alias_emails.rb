class AddAliasEmails < ActiveRecord::Migration[6.0]
  def change
    add_column(:districts, :aliases, :string, array: true)
  end
end
