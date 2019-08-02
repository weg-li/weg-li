class CreateBetaUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :beta_users do |t|
      t.string :email

      t.timestamps
    end
  end
end
