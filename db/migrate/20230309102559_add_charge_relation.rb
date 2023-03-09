# frozen_string_literal: true

class AddChargeRelation < ActiveRecord::Migration[7.0]
  def change
    change_table :notices do |t|
      t.string :tbnr, index: true, null: true
    end

    reversible do |dir|
      dir.up do
        Charge::UPDATED_CHARGES.each do |_, charge, tbnr_standard, tbnr_hinder, _, _|
          puts charge
          next if tbnr_standard.blank? || charge == "Sonstiges Parkvergehen (siehe Hinweise)"

          Notice.where("charge = ?", charge).where(severity: 0).update_all(tbnr: tbnr_standard)
          Notice.where("charge = ?", charge).where(severity: [1, 2]).update_all(tbnr: tbnr_hinder || tbnr_standard)
        end

        [
          [
            "Parken auf einem Gehweg, der durch Parkflächenmarkierung zum Gehwegparken freigegeben war, bei mehr als 2,8 t zulässiger Gesamtmasse",
            "141042",
          ],
          [
            "Parken auf einem Parkplatz (Zeichen 314), obwohl dies durch Zusatzzeichen *) für Sie verboten war",
            "142202",
          ],
          [
            "Parken auf einer schmalen Fahrbahn gegenüber einer Grundstückseinfahrt/Grundstücks-ausfahrt",
            "112302",
          ],
          [
            "Parken im eingeschränkten Haltverbot für eine Zone (Zeichen 290.1, 290.2)",
            "141118",
          ],
          [
            "Parken in der Einbahnstraße entgegen der Fahrtrichtung",
            "112076",
          ],
          [
            "Parken in einem Fußgängerbereich, der (durch Zeichen 239/242.1, 242.2/250) gesperrt war",
            "141184",
          ],
          [
            "Parken verbotswidrig auf einem Schutzstreifen für den Radverkehr (Zeichen 340)",
            "142170",
          ],
          [
            "Sonstiges Parkvergehen (siehe Hinweise)",
            "000000",
          ],
        ].each do |charge, tbnr|
          puts "#{charge} #{tbnr}"
          Notice.where(charge:).update_all(tbnr:)
        end
        Notice.where("tbnr IS NULL").update_all(tbnr: "000000")

        # make sure all set
        change_column :notices, :tbnr, :string, null: false
        # allow nil anyways
        change_column :notices, :tbnr, :string, null: true
      end
    end
  end
end
