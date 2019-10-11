class AddDurationToNotice < ActiveRecord::Migration[6.0]
  def change
    add_column(:notices, :duration, :integer)

    reversible do |dir|
      dir.up do
        ids = Notice.parked.pluck(:id)
        execute "UPDATE notices SET duration = 3, flags = flags - 2 WHERE id IN(#{ids.join(',')})"
        ids = Notice.parked_one_hour.pluck(:id)
        execute "UPDATE notices SET duration = 60, flags = flags - 16 WHERE id IN(#{ids.join(',')})"
        ids = Notice.parked_three_hours.pluck(:id)
        execute "UPDATE notices SET duration = 180, flags = flags - 8 WHERE id IN(#{ids.join(',')})"
      end
    end
  end
end
