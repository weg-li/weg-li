class AddressToNotice < ActiveRecord::Migration[6.0]
  def change
    add_column(:notices, :street, :string)
    add_column(:notices, :zip, :string)
    add_column(:notices, :city, :string)

    reversible do |dir|
      dir.up do
        # Notice.shared.where('address IS NOT NULL and city IS NULL').each do |notice|
        #   notice.prefill_address_fields
        #   notice.save!(validate: false)
        # end
      end
    end
  end
end
