namespace :data do
  task import: :environment do
    require 'byebug'
    require 'csv'

    CSV.foreach(Rails.root.join('bkat/data/Tatbestandstabelleneintrag.csv'), headers: true, quote_char: "'") do |row|
      # Schluessel, Zeile,  Von,  Bis,  Behinderung,  hatTatbestandBE,  hatZusatzinformationTatbestandstabelle, gehoertZuTatbestandstabelleBE
      # '1',        '1',    '0',  '20', 'N',          '103636',         '',                                     '703000'
      params = {
        row_id: row['Schluessel'],
        row_number: row['Zeile'],
        from: row['Von'],
        to: row['Bis'],
        impediment: row['Behinderung'] == 'J',
        tbnr: row['hatTatbestandBE'],
        charge_detail: row['hatZusatzinformationTatbestandstabelle'],
        table_id: row['gehoertZuTatbestandstabelleBE'],
      }
      puts params
      ChargeVariant.create!(params)
    end

    CSV.foreach(Rails.root.join('bkat/data/TatbestandBE.csv'), headers: true, quote_char: "'") do |row|
      # TBNR,Tatbestandstext,Geldbusse,Rechtsgrundlage,Fahrverbot,FaP,Punkte,validFrom,validTo,hatKonkretisierungsart,historyUser,
      # hatKlassifizierung,hatTatbestandstabelleBE,hatTatbestandsvorschriftBE,gehoertZuTatbestandstabelleneintrag,
      # erforderlicheKonkretisierungen,AnzahlErforderlicheKonkretisierungen,Hoechstgeldbusse
      params = {
        tbnr: row['TBNR'],
        description: row['Tatbestandstext'],
        fine: row['Geldbusse'],
        bkat: row['Rechtsgrundlage'],
        penalty: row['Fahrverbot'],
        fap: row['FaP'].presence,
        points: row['Punkte'],
        valid_from: row['validFrom'],
        valid_to: row['validTo'],
        implementation: row['hatKonkretisierungsart'],
        classification: row['hatKlassifizierung'],
        variant_table_id: row['hatTatbestandstabelleBE'],
        rule_id: row['hatTatbestandsvorschriftBE'],
        table_id: row['gehoertZuTatbestandstabelleneintrag'],
        required_refinements: row['erforderlicheKonkretisierungen'],
        number_required_refinements: row['AnzahlErforderlicheKonkretisierungen'],
        max_fine: row['Hoechstgeldbusse'],
      }
      puts params
      Charge.create!(params)
    end
  end
end
