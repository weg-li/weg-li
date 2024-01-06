class AddAutofillSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :autosuggest, :integer, default: 0, null: false
  end
end
