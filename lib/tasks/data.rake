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

      district = District.find_by(zip: zip)
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

  task import_brands: :environment do
    Brand.connection.truncate("brands")
    Vehicle.cars.each do |item|
      params = {
        name: item["brand"],
        token: item["brand"].parameterize,
        kind: :car,
        aliases: item["aliases"],
        models: item["models"],
      }
      puts params
      Brand.create!(params)
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

  task import_signs: :environment do
    Sign.connection.truncate("signs")
    CSV.foreach(Rails.root.join("config/data/schilder.csv"), headers: false) do |row|
      # Nr,Bezeichnung
      params = {
        number: row[0],
        description: row[1],
      }
      puts params
      Sign.create!(params)
    end
  end

  task add_parts: :environment do
    zips_and_city.group_by { |row| row["PLZ"] }.each do |zip, rows|
      parts = rows.map { |row| row["Ortstteil"] }.compact.uniq
      puts "#{zip} parts #{parts}"
      name = rows.first["Ort"].strip
      district = District.find_by(zip: zip)
      if district
        puts "#{zip} old name #{district.name} new name #{name}" if name != district.name
        district.update_column(:parts, parts)
      else
        state = zip_to_state.dig(zip, "Bundesland") || "Bayern"
        district = District.new(zip: zip, parts: parts, name: name, state: state, prefixes: [zip_to_prefix[zip]], email: "info@#{name.downcase.parameterize}.de")
        puts "creating district #{zip} #{name}"
        district.save(validate: false)
      end
    end
  end

  task add_plates: :environment do
    Plate.connection.truncate("plates")
    plates.each do |prefix, name|
      zips = zip_to_prefix.select { |_zip, p| p == prefix }.keys
      Plate.create!(prefix: prefix, name: name, zips: zips)
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

  def zip_to_state
    # PLZ;PLZ1;PLZ2;PLZ3;Ort;Landkreis;Bundesland
    # 10115;1;10;101;Berlin;Berlin;Berlin
    @zip_to_state ||= CSV.parse(File.read("config/data/zip_to_state.csv"), col_sep: ";", headers: true).to_h { |row| [row["PLZ"], row] }
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

  def plates
    @plates ||= JSON.load(Rails.root.join("config/data/plates.json"))
  end
end
