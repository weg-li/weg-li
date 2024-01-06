class CreateCharges < ActiveRecord::Migration[6.0]
  def change
    create_table :charges do |t|
      # TBNR,     Tatbestandstext,                            Geldbusse,Rechtsgrundlage,                              Fahrverbot, FaP,  Punkte, validFrom,                  validTo,                    hatKonkretisierungsart, historyUser,  hatKlassifizierung, hatTatbestandstabelleBE,  hatTatbestandsvorschriftBE,   gehoertZuTatbestandstabelleneintrag,  erforderlicheKonkretisierungen,     AnzahlErforderlicheKonkretisierungen, Hoechstgeldbusse
      # '112050', 'Sie hielten verbotswidrig auf dem Gehweg.','10.00',  '§ 12 Abs. 4, § 49 StVO; § 24 StVG; -- BKat', '',         'B',  '1',    '2002-01-01-00.00.00.0000', '2014-04-30-11.59.99.9999', '',                     'pmOWI',      '5',                '712031',                 '272',                        '',                                   '00000000000000000000000000000000', '0',                                  '0.00'
      t.string :tbnr, index: true
      t.string :description
      t.decimal :fine
      t.string :bkat
      t.string :penalty
      t.string :fap
      t.integer :points
      t.timestamp :valid_from
      t.timestamp :valid_to
      t.integer :implementation
      t.integer :classification, index: true
      t.integer :variant_table_id
      t.integer :rule_id
      t.integer :table_id
      t.string :required_refinements
      t.integer :number_required_refinements
      t.decimal :max_fine

      t.timestamps
    end

    create_table :charge_variants do |t|
      # Schluessel, Zeile,  Von,  Bis,  Behinderung,  hatTatbestandBE,  hatZusatzinformationTatbestandstabelle, gehoertZuTatbestandstabelleBE
      # '1',        '1',    '0',  '20', 'N',          '103636',         '',                                     '703000'
      t.integer :row_id
      t.integer :row_number
      t.decimal :from
      t.decimal :to
      t.boolean :impediment
      t.string :tbnr, index: true
      t.integer :charge_detail
      t.integer :table_id, index: true

      t.timestamps
    end
  end
end
