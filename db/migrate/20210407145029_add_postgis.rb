class AddPostgis < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute "CREATE EXTENSION IF NOT EXISTS postgis;"
        execute "CREATE INDEX index_notices_on_lonlat ON notices USING GIST (lonlat);"
        execute "UPDATE notices SET lonlat = ST_MakePoint(longitude, latitude) WHERE lonlat IS NULL AND longitude IS NOT NULL AND latitude IS NOT NULL;"
      end
    end
  end
end
