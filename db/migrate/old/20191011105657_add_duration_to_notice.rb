class AddDurationToNotice < ActiveRecord::Migration[6.0]
  def change
    add_column(:notices, :duration, :integer, default: 1)
    add_column(:notices, :severity, :integer, default: 0)

    reversible do |dir|
      dir.up do
        # ids = Notice.parked.pluck(:id)
        # execute "UPDATE notices SET duration = 3, flags = flags - 2 WHERE id IN(#{ids.join(',')})" if ids.present?
        # ids = Notice.parked_one_hour.pluck(:id)
        # execute "UPDATE notices SET duration = 60, flags = flags - 16 WHERE id IN(#{ids.join(',')})" if ids.present?
        # ids = Notice.parked_three_hours.pluck(:id)
        # execute "UPDATE notices SET duration = 180, flags = flags - 8 WHERE id IN(#{ids.join(',')})" if ids.present?
        #
        # ids = Notice.hinder.pluck(:id)
        # execute "UPDATE notices SET severity = 1, flags = flags - 4 WHERE id IN(#{ids.join(',')})" if ids.present?
      end
    end
  end
end
