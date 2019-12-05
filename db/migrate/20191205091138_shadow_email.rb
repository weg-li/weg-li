class ShadowEmail < ActiveRecord::Migration[6.0]
  def change
    add_column(:districts, :flags, :integer, default: 0)
  end
end
