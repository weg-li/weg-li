class RemoveChargeFromNotices < ActiveRecord::Migration[7.0]
  def change
    rename_column :notices, :charge, :old_charge
  end
end
