class AddConfigToDistrict < ActiveRecord::Migration[6.1]
  def change
    add_column :districts, :config, :integer, default: 0
    reversible do |dir|
      dir.up do
        execute "UPDATE districts SET config = 1 WHERE email = 'bgst-verkehr2@dresden.de'"
        execute "UPDATE districts SET config = 2 WHERE email = 'verkehrsueberwachung.kvr@muenchen.de'"
      end
    end
  end
end
