class AddDistrictToUserAndNotice < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        rename_column(:notices, :district, :district_legacy)
      end
    end
    add_reference(:notices, :district, index: true)

    add_column(:users, :street, :string)
    add_column(:users, :zip, :string)
    add_column(:users, :city, :string)
  end
end
