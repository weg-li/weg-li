class AddPostgis < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute "CREATE EXTENSION IF NOT EXISTS postgis;"
        execute "ALTER TABLE notices ADD COLUMN lonlat geometry(Point, 4326);"
        execute "CREATE INDEX index_notices_on_lonlat ON notices USING GIST (lonlat);"
        execute "UPDATE notices SET lonlat = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326) WHERE lonlat IS NULL AND longitude IS NOT NULL AND latitude IS NOT NULL;"
      end
    end
  end
end
