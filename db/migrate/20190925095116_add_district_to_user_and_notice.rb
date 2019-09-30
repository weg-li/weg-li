class AddDistrictToUserAndNotice < ActiveRecord::Migration[6.0]
  def change
    add_reference(:notices, :district, index: true)
    reversible do |dir|
      dir.up do
        rename_column(:notices, :district, :district_legacy)
        Notice.where('district_legacy IS NOT NULL and district_id IS NULL').in_batches(of: 1000) do |notices|
          notices.each do |notice|
            district = District.from_zip(DistrictLegacy.by_name(notice.district_legacy).zip)
            notice.update_attribute(:district_id, district.id)
          end
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
