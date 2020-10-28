class AddDateToChargeVariant < ActiveRecord::Migration[6.0]
  def change
    add_column :charge_variants, :date, :timestamp

    add_index :charge_variants, [:table_id, :date]
  end
end
