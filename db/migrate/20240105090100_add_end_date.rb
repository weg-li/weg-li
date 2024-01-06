class AddEndDate < ActiveRecord::Migration[7.1]
  def change
    rename_column :notices, :date, :start_date
    add_column :notices, :end_date, :timestamp, null: true
    add_index :notices, :end_date

    reversible do |dir|
      dir.up do
        Notice.where("start_date IS NOT NULL").update_all("end_date = start_date + (notices.duration::TEXT || ' minutes')::INTERVAL")
      end
    end
  end
end
