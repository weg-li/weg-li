class ChangeSharedSecretToTokenOnNotices < ActiveRecord::Migration[4.2]
  def change
    rename_column :notices, :shared_secret, :token
  end
end
