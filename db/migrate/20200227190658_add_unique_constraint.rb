class AddUniqueConstraint < ActiveRecord::Migration[6.0]
  def change
    add_index(:notices, :token, unique: true)
  end
end
