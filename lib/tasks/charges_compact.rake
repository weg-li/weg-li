# frozen_string_literal: true

namespace :data do
  desc "Generate compact parking charges TSV from TatbestandBE.csv"
  task generate_compact_charges: :environment do
    require "csv"

    csv_path = Rails.root.join("bkat/data/TatbestandBE.csv")
    out_path = Rails.root.join("bkat/data/charges_compact.tsv")

    charges = []
    CSV.foreach(csv_path, headers: true, quote_char: "'") do |row|
      next unless row["hatKlassifizierung"] == "5"
      next unless row["validTo"].to_s.strip.empty?

      charges << { tbnr: row["TBNR"], desc: row["Tatbestandstext"], valid_from: row["validFrom"].to_s }
    end

    rows = {}
    all_cols = {}
    dropped = []

    charges.each do |c|
      l = compact_location(c[:desc])
      ck = compact_col_key(c[:desc])
      rows[l] ||= {}

      if rows[l][ck]
        existing = rows[l][ck]
        newer = c[:valid_from] > existing[:valid_from] ||
                (c[:valid_from] == existing[:valid_from] && c[:tbnr] > existing[:tbnr])
        if newer
          dropped << "#{l} [#{ck}]: kept #{c[:tbnr]}, dropped #{existing[:tbnr]}"
          rows[l][ck] = { tbnr: c[:tbnr], valid_from: c[:valid_from] }
        else
          dropped << "#{l} [#{ck}]: kept #{existing[:tbnr]}, dropped #{c[:tbnr]}"
        end
      else
        rows[l][ck] = { tbnr: c[:tbnr], valid_from: c[:valid_from] }
      end
      all_cols[ck] = true
    end

    col_order = %w[
      p p_beh p_gef p_unf
      p_30m p_1h p_beh_1h p_gef_1h p_unf_1h
      p_2h p_3h p_beh_3h p_gef_3h p_unf_3h
      h h_beh h_gef h_unf
      u u_30m u_1h u_2h u_3h
    ]
    used_cols = col_order.select { |c| all_cols[c] }

    lines = ["location\t#{used_cols.join("\t")}"]
    rows.sort_by { |k, _| k }.each do |l, cols|
      vals = used_cols.map { |c| cols[c] ? cols[c][:tbnr] : "" }
      lines << "#{l}\t#{vals.join("\t")}"
    end

    File.write(out_path, "#{lines.join("\n")}\n")

    mapped = rows.values.flat_map { |cols| cols.values.map { |v| v[:tbnr] } }
    puts "#{rows.size} locations, #{used_cols.size} columns, #{mapped.size} mapped"
    puts "Columns: #{used_cols.join(', ')}"

    if dropped.any?
      puts "#{dropped.size} superseded TBNRs dropped (older duplicates)"
    end
  end
end

def compact_strip_qualifiers(desc)
  d = desc.dup
  d.gsub!(/,?\s*und behinderten \+\) dadurch Andere\.?/, "")
  d.gsub!(/,?\s*und gefährdeten \+\) dadurch Andere\.?/, "")
  d.gsub!(/,?\s*Es kam zum Unfall\.?/, "")
  d.gsub!(/\s*mit Behinderung\.?/, "")
  d.gsub!(/\s*länger als 3 Stunden/, "")
  d.gsub!(/\s*-?\s*länger als 2 Stunden/, "")
  d.gsub!(/\s*länger als eine Stunde/, "")
  d.gsub!(/\s*länger als 1 Stunde/, "")
  d.gsub!(/\s*-?\s*länger als 30 Minuten/, "")
  d.gsub!(/, wodurch Andere behindert \+\) wurden\.?/, "")
  d.gsub!(/^Sie (parkten|hielten|überschritten|stellten|benutzten|nahmen|ließen)\s*/, "")
  d.strip.gsub(/\.\z/, "")
end

def compact_col_key(desc)
  act = case desc
        when /^Sie (parkten|stellten|benutzten|nahmen|ließen)/ then "p"
        when /^Sie hielten/ then "h"
        when /^Sie überschritten/ then "u"
        else "p" # rubocop:disable Lint/DuplicateBranch -- default to parking
        end
  sev = case desc
        when /Unfall/ then "_unf"
        when /gefährdeten/ then "_gef"
        when /behinderten|Behinderung|wodurch Andere behindert/ then "_beh"
        else ""
        end
  dur = case desc
        when /länger als 3 Stunden/ then "_3h"
        when /länger als 2 Stunden/ then "_2h"
        when /länger als (eine |1 )Stunde/ then "_1h"
        when /länger als 30 Minuten/ then "_30m"
        else ""
        end
  "#{act}#{sev}#{dur}"
end

def compact_location(desc)
  n = compact_strip_qualifiers(desc)
  case n
  when /Schutzstreifen.*Radverkehr/ then "Schutzstreifen Rad"
  when /Radfahrstreifen|Radweg.*Zeichen.*237/ then "Radweg beschildert"
  when /unbeschilderten Radweg/ then "Radweg unbeschildert"
  when /Fahrradstraße/ then "Fahrradstraße"
  when /Geh- und Radweg/ then "Geh+Radweg"
  when /Gehweg.*Parkflächenmarkierung.*2,8/ then "Gehweg >2,8t Markierung"
  when /Gehweg.*Zeichen 315.*verboten/ then "Gehweg Z315 verboten"
  when /Gehweg.*Zeichen 315.*2,8/ then "Gehweg Z315 >2,8t"
  when /Gehweg.*Zeichen 315.*Aufstellungsart/ then "Gehweg Z315 Aufstellung"
  when /Gehweg.*Zeichen 315.*Zeit/ then "Gehweg Z315 Zeitüberschr"
  when /Gehweg.*Schachtdeckel/ then "Gehweg Schachtdeckel"
  when /auf einem Fußgängerüberweg/ then "Fußgängerüberweg"
  when /5 Metern? vor einem Fußgängerüberweg/ then "Fußgängerüberweg <5m"
  when /Gehwegparken.*nicht auf dem rechten/ then "Gehweg Z315 falsche Seite"
  when /Gehwegparken.*Einbahnstraße/ then "Gehweg Z315 Einbahnstr."
  when /Zeichen 315 auf dem Gehweg.*Zusatzzeichen/ then "Gehweg Z315 Zusatzz. verboten"
  when /verbotswidrig auf dem Gehweg/ then "Gehweg"
  when /Gehweg/ then "Gehweg" # rubocop:disable Lint/DuplicateBranch -- catch-all for remaining Gehweg variants
  when /absoluten Haltverbot/ then "Abs. Haltverbot Z283"
  when /eingeschränkten Haltverbot.*Zone.*Höchstparkdauer/ then "Haltverbot Zone Zeitüberschr"
  when /eingeschränkten Haltverbot.*Zone.*lesbar/ then "Haltverbot Zone o. Scheibe"
  when /eingeschränkten Haltverbot.*Zone.*eingestellt/ then "Haltverbot Zone Scheibe falsch"
  when /eingeschränkten Haltverbot.*Zone/ then "Eingeschr. Haltverbot Zone"
  when /eingeschränkten Haltverbot.*Bewohner/ then "Eingeschr. Haltverbot Bewohner"
  when /eingeschränkten Haltverbot|Haltverbot.*286/ then "Eingeschr. Haltverbot Z286"
  when /Grenzmarkierung.*Haltverbot.*Bussonder/ then "Grenzmark. Bus-Haltverbot"
  when /Grenzmarkierung.*Parkverbot.*Haltestelle/ then "Grenzmark. Haltest-Parkverbot"
  when /Grenzmarkierung.*Haltverbot/ then "Grenzmark. Haltverbot"
  when /Grenzmarkierung.*Parkverbot/ then "Grenzmark. Parkverbot"
  when /Bussonderfahrstreifen/ then "Bussonderfahrstreifen"
  when /15 Meter.*Haltestellenschild/ then "Bushaltestelle <15m"
  when /Taxenstand/ then "Taxenstand"
  when /15 Minuten.*zweite.*Reihe/ then "Zweite Reihe >15min"
  when /zweite.*Reihe/ then "Zweite Reihe"
  when /Feuerwehr.*5 Meter/ then "Feuerwehr <5m"
  when /Feuerwehr.*Zufahrt/ then "Feuerwehr Zufahrt"
  when /Feuerwehr/ then "Feuerwehr"
  when /schwerbehinderte|Rollstuhl/ then "Behindertenparkplatz"
  when /Autobahn|Kraftfahrstraße/ then "Autobahn/Kraftfahrstr"
  when /linken Fahrbahnseite|linken Seitenstreifen/ then "Linke Fahrbahnseite"
  when /Seitenstreifen/ then "Seitenstreifen"
  when /8 Meter.*Kreuzung.*Radweg/ then "Kreuzung <8m (Radweg)"
  when /5 Meter.*vor.*Kreuzung/ then "Kreuzung <5m vor"
  when /5 Meter.*hinter.*Kreuzung/ then "Kreuzung <5m hinter"
  when /Bordsteinabsenkung/ then "Bordsteinabsenkung"
  when /enge.*Restfahrbahn|unübersichtlich.*Restfahrbahn/ then "Enge Stelle Restfahrbahn"
  when /enge|unübersichtlich/ then "Enge/unübers. Stelle"
  when /schmale.*Grundstück/ then "Schmale Fahrb. Grundst"
  when /scharfen Kurve.*Verkehrsfläche/ then "Scharfe Kurve Restfahrbahn"
  when /scharfen Kurve/ then "Scharfe Kurve"
  when /Bahnübergang/ then "Bahnübergang"
  when /abgelaufenen Parkuhr/ then "Parkuhr abgelaufen"
  when /Parkuhr.*Parkscheibe.*lesbar/ then "Parkuhr defekt o. Scheibe"
  when /Parkuhr.*Parkscheibe.*eingestellt/ then "Parkuhr defekt Scheibe falsch"
  when /Parkuhr.*zulässige/ then "Parkuhr Zeitüberschr"
  when /Parkscheinautomat.*ohne gültigen/ then "Parkscheinaut. o. Schein"
  when /Parkscheinautomat.*gut lesbar/ then "Parkscheinaut. n. lesbar"
  when /Parkscheinautomat.*nicht funktionsfähig.*lesbar/ then "Parkscheinaut. defekt o. Scheibe"
  when /Parkscheinautomat.*nicht funktionsfähig.*eingestellt/ then "Parkscheinaut. defekt Scheibe falsch"
  when /Parkscheinautomat.*zulässige|Parkscheinautomaten die auf dem Parkschein angegebene/ then "Parkscheinaut. Zeitüberschr"
  when /Parkraumbewirtschaftung.*Höchstparkdauer/ then "Parkraumzone Zeitüberschr"
  when /Parkraumbewirtschaftung.*lesbar/ then "Parkraumzone o. Scheibe"
  when /Parkraumbewirtschaftung.*eingestellt/ then "Parkraumzone Scheibe falsch"
  when /Parkraumbewirtschaftung/ then "Parkraumzone"
  when /Sonderparkplatz.*Bewohner/ then "Bewohnerparkplatz"
  when /Zeichen.*314.*315.*Höchstparkdauer/ then "Z314/315 Zeitüberschr"
  when /Zeichen.*314.*315.*lesbar/ then "Z314/315 o. Scheibe"
  when /Zeichen.*314.*315.*eingestellt/ then "Z314/315 Scheibe falsch"
  when /Parkplatz.*Zeichen 314.*verboten/ then "Z314 Parkverbot"
  when /verkehrsberuhigt/ then "Verkehrsber. Bereich"
  when /Kreisverkehr/ then "Kreisverkehr"
  when /Grundstück/ then "Grundstückseinfahrt"
  when /Fußgängerfurt.*Lichtzeichen/ then "Fußgängerfurt Lichtzeichen"
  when /Lichtzeichen/ then "Lichtzeichen <10m"
  when /Fahrstreifenbegrenzung|295.*296.*3 Met/ then "Fahrstreifenbegr. <3m"
  when /Fahrbahnbegrenzung.*295/ then "Links Fahrbahnbegr. Z295"
  when /Richtungspfeile|Zeichen 297/ then "Richtungspfeile Z297"
  when /rechten Fahrbahnrand/ then "Nicht rechter Rand"
  when /außerhalb.*Ortschaft.*Vorfahrt/ then "Vorfahrtsstr. außerorts"
  when /Vorfahrt|Andreaskreuz/ then "Vorfahrtszeichen <10m"
  when /Reitweg/ then "Reitweg"
  when /Zeichen <?257/ then "Verkehrsverbot Z257"
  when /Zeichen <?25[0-3]|Zeichen <?255|Zeichen <?260/ then "Verkehrsverbot Z250ff"
  when /Zeichen <?26[2-7]/ then "Beschränkung Z262ff"
  when /elektrisch/ then "E-Fahrzeug-Parkplatz"
  when /Carsharing/ then "Carsharing-Parkplatz"
  when /Luftverunreinigung|Feinstaub/ then "Umweltzone"
  when /Parkflächen/ then "Gekennz. Parkflächen"
  when /nicht wegfahren/ then "Zuparken"
  when /Andere$/ then "Allg. Behinderung"
  when /Fußgängerfurt/ then "Fußgängerfurt"
  when /Verkehrsinsel|Grünstreifen/ then "Verkehrsinsel/Grünstreifen"
  when /Einbahnstraße.*entgegen/ then "Einbahnstr. Gegenrichtung"
  when /Einfädelungsstreifen|Ausfädelungsstreifen/ then "Ein-/Ausfädelungsstr."
  when /Kraftfahrzeug.*7,5.*Gebiet/ then "Kfz >7,5t Wohngebiet"
  when /Kraftfahrzeuganhänger.*2 t.*Gebiet/ then "Anhänger >2t Wohngebiet"
  when /Kraftfahrzeuganhänger.*ohne Zugfahrzeug/ then "Anhänger o. Zugfzg >2Wo"
  when /Schienenfahrzeug/ then "Schienenfahrzeug-Fahrraum"
  when /Vorrang.*Parklücke/ then "Parklücke Vorrang"
  when /nicht Platz sparend/ then "Nicht platzsparend"
  when /Sperrfläche.*298/ then "Sperrfläche Z298"
  when /Nothalte|Pannenbucht/ then "Nothalte-/Pannenbucht"
  else n[0..34]
  end
end
