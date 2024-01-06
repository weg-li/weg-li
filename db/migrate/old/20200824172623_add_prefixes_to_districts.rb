class AddPrefixesToDistricts < ActiveRecord::Migration[6.0]
  def change
    change_column(:districts, :prefix, :string, array: true, default: [], using: "(string_to_array(prefix, ','))")
  end
end
