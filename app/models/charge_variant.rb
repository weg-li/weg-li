class ChargeVariant < ApplicationRecord
  belongs_to :charge, -> { active }, foreign_key: :tbnr, primary_key: :tbnr, optional: true

  def charge_detail_description
    CHARGE_DETAIL[charge_detail] || '-'
  end

  CHARGE_DETAIL = {
    1 => 'Halten',
    2 => 'Parken',
    3 => 'Parken > 15 Minuten',
    4 => 'Parken > 1 Stunde',
    5 => 'Parken > 3 Stunden',
    6 => 'mehr als 5 Minuten',
    7 => '>2 Geschw.-üb.sch.',
  }
end
