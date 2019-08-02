class AddStripeInfoToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :stripe_customer_token, :string
  end
end
