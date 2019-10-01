class AddDistrictToUserAndNotice < ActiveRecord::Migration[6.0]
  def change
    add_reference(:notices, :district, index: true)
    reversible do |dir|
      dir.up do
        rename_column(:notices, :district, :district_legacy)
        DistrictLegacy.all.each do |dis_leg|
          district = District.from_zip(dis_leg.zip)
          Notice.where(district_legacy: dis_leg.name, district_id: nil).update_all(district_id: district.id) if district.present?
        end
      end
      dir.down do
        rename_column(:notices, :district_legacy, :district)
      end
    end

    add_column(:users, :street, :string)
    add_column(:users, :zip, :string)
    add_column(:users, :city, :string)

    reversible do |dir|
      dir.up do
        User.not_disabled.not_ghost.where('address IS NOT NULL and city IS NULL').each do |user|
          user.prefill_address_fields
          user.save!(validate: false)
        end
      end
    end
  end
end
