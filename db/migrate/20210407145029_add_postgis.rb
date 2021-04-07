class AddPostgis < ActiveRecord::Migration[6.1]
  def change
    change_table :notices do |t|
      t.st_point :lonlat, geographic: true

      t.index :lonlat, using: :gist
    end

    reversible do |dir|
      dir.up do
        execute "CREATE EXTENSION IF NOT EXISTS postgis;"
        execute "UPDATE notices SET lonlat = ST_MakePoint(longitude, latitude) WHERE lonlat IS NULL AND longitude IS NOT NULL AND latitude IS NOT NULL;"
      end
    end
  end
end
