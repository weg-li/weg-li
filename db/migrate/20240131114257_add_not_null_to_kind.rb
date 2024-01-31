class AddNotNullToKind < ActiveRecord::Migration[7.1]
  def change
    Brand.where(kind: nil).update_all(kind: 0)
    change_column_null :brands, :kind, false
  end
end
