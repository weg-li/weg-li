class AddMetaToOpenings < ActiveRecord::Migration[4.2]
  def change
    add_column :openings, :meta, :json
  end
end
