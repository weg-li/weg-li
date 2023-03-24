# frozen_string_literal: true

require "csv"

namespace :data do
  task :export do
    data = File.readlines(Rails.root.join("bkat/TBKAT.DAT"), chomp: true)
    name = nil
    data.each do |line|
      if name.nil? || line[0] == "."
        name = line.gsub(/.*\./, "")
        puts name
        File.write(Rails.root.join("bkat/data/#{name}.csv"), "")
      else
        File.open(Rails.root.join("bkat/data/#{name}.csv"), "a") { |f| f.puts line }
      end
    end
  end

  task fill_up_districts: :environment do
    zips_and_city.each do |row|
      # PLZ,Ort,Ortstteil,
      zip = row["PLZ"]

      puts zip
      next if zip.blank?

      district = District.from_zip(zip)
      if district.present?
        Rails.logger.info("found #{zip}: #{district.id}")
      else
        name = row["Ort"]
        source = District.active.where("name = :name AND zip LIKE :zip", name:, zip: "#{zip.first(2)}%").first
        if source.present?
          Rails.logger.info("found source for #{zip}: #{source.id}")
          district = source.dup
          district.zip = zip
          district.prefixes ||= [zip_to_prefix[zip]]
          district.save!
        else
          Rails.logger.info("could not find anything for #{zip}")
        end
      end
    end
  end

  task extend_district_data: :environment do
    zips_and_osm.each do |row|
      zip = row["plz"]
      district = from_zip(zip)
      if district.present?
        Rails.logger.info("found #{zip}: #{district.id}")
      else
        source = District.active.where("name = :name AND zip LIKE :zip", name: row["ort"], zip: "#{zip.first}%").first
        if source.present?
          Rails.logger.info("found source for #{zip}: #{source.id}")
          district = source.dup
          district.zip = zip
          district.osm_id = row["osm_id"]
          district.state = row["bundesland"]
          district.prefix = [zip_to_prefix[zip]]
          district.save!
        else
          Rails.logger.info("could not find anything for #{zip}")
        end
      end
    end
  end

  task import_charge_variants: :environment do
    ChargeVariant.connection.truncate("charge_variants")
    CSV.foreach(Rails.root.join("bkat/data/Tatbestandstabelleneintrag.csv"), headers: true, quote_char: "'") do |row|
      # Schluessel, Zeile,  Von,  Bis,  Behinderung,  hatTatbestandBE,  hatZusatzinformationTatbestandstabelle, gehoertZuTatbestandstabelleBE
      # '1',        '1',    '0',  '20', 'N',          '103636',         '',                                     '703000'
      params = {
        row_id: row["Schluessel"],
        row_number: row["Zeile"],
        from: row["Von"],
        to: row["Bis"],
        impediment: row["Behinderung"] == "J",
        tbnr: row["hatTatbestandBE"],
        date: row["Datum"],
        charge_detail: row["hatZusatzinformationTatbestandstabelle"],
        table_id: row["gehoertZuTatbestandstabelleBE"],
      }
      puts params
      ChargeVariant.create!(params)
    end
  end

  task import_charges: :environment do
    Charge.connection.truncate("charges")
    CSV.foreach(Rails.root.join("bkat/data/TatbestandBE.csv"), headers: true, quote_char: "'") do |row|
      # TBNR,Tatbestandstext,Geldbusse,Rechtsgrundlage,Fahrverbot,FaP,Punkte,validFrom,validTo,hatKonkretisierungsart,historyUser,
      # hatKlassifizierung,hatTatbestandstabelleBE,hatTatbestandsvorschriftBE,gehoertZuTatbestandstabelleneintrag,
      # erforderlicheKonkretisierungen,AnzahlErforderlicheKonkretisierungen,Hoechstgeldbusse
      params = {
        tbnr: row["TBNR"],
        description: row["Tatbestandstext"],
        fine: row["Geldbusse"],
        bkat: row["Rechtsgrundlage"],
        penalty: row["Fahrverbot"],
        fap: row["FaP"].presence,
        points: row["Punkte"],
        valid_from: row["validFrom"],
        valid_to: row["validTo"],
        implementation: row["hatKonkretisierungsart"],
        classification: row["hatKlassifizierung"],
        variant_table_id: row["hatTatbestandstabelleBE"],
        rule_id: row["hatTatbestandsvorschriftBE"],
        table_id: row["gehoertZuTatbestandstabelleneintrag"],
        required_refinements: row["erforderlicheKonkretisierungen"],
        number_required_refinements: row["AnzahlErforderlicheKonkretisierungen"],
        max_fine: row["Hoechstgeldbusse"],
      }
      puts params
      Charge.create!(params)
    end
  end

  private

  def zips_and_osm
    # osm_id,ort,plz,bundesland
    @zips_and_osm ||= CSV.parse(File.read("config/data/zips_and_osm.csv"), headers: true)
  end

  def zips_and_city
    # PLZ,Ort,Ortstteil,
    # 01067,Dresden,,
    @zips_and_city ||= CSV.parse(File.read("config/data/zips_and_city.csv"), headers: true)
  end

  def opengeodb
    @opengeodb ||= CSV.parse(File.read("config/data/opengeodb.csv"), col_sep: "\t", quote_char: nil, headers: true)
  end

  def zip_to_plate_prefix_mapping
    @zip_to_plate_prefix_mapping ||= opengeodb.each_with_object({}) do |entry, hash|
      next unless entry["plz"]

      zips = entry["plz"].split(",")
      zips.each { |zip| hash[zip] = entry["kz"] if entry["kz"] }
    end.to_h
  end

  def zip_to_prefix
    @zip_to_prefix ||= JSON.load(Rails.root.join("config/data/zip_to_prefix.json"))
  end
end
