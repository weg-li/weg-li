class AddDurationToBlueprint < ActiveRecord::Migration[8.1]
  def change
    add_column :blueprints, :duration, :integer
  end
end
