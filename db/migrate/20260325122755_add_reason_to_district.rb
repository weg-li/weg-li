class AddReasonToDistrict < ActiveRecord::Migration[8.1]
  def change
    add_column :districts, :reason, :string
  end
end
