class DistrictData < ActiveRecord::Migration[6.0]
  def change
    add_column(:districts, :osm_id, :integer)
    add_column(:districts, :state, :string)
  end
end
