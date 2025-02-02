class CreateHomepages < ActiveRecord::Migration[7.2]
  def change
    create_view :homepages, materialized: true
  end
end
