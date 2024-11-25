# frozen_string_literal: true

xml.instruct!

xml.OWIGMDEData Version: "1" do
  xml.comment! "Required"
  xml.Header Herkunft: "weg.li", Sachbearbeitername: notice.wegli_email
  xml.comment! "Multiple"
  xml.Mandant do
    xml.comment! "Multiple"
    xml.Fall FallArt: "VOWI", GPS: "#{notice.latitude};#{notice.longitude}" do
      xml.comment! "Required"
      xml.Beteiligte do
        xml.comment! "Required"
        xml.Beteiligter Funktion: "keine", Typ: "Anzeigenerstatter" do
          xml.comment! "Optional"
          xml.Kontakt do
            xml.Anschrift do
              xml.comment! "Default is '-' weg.li does not use salutations"
              xml.Anrede "-"
              xml.comment! "Required"
              xml.Vorname user.first_name
              xml.comment! "Required"
              xml.Name user.last_name
              xml.comment! "Required"
              xml.Strasse user.street_without_housenumber
              xml.comment! "Required"
              xml.Hausnummer user.housenumber
              xml.comment! "Optional"
              xml.Adresszusatz user.appendix
              xml.comment! "Required"
              xml.PLZ user.zip
              xml.comment! "Required"
              xml.Ort user.city
              xml.comment! "Default is 'D' weg.li permits DE only"
              xml.Landeskennzeichen "D"
            end
            xml.comment! "Required"
            xml.EMail user.email
            xml.comment! "Optional"
            xml.Telefon user.phone if user.phone.present?
          end
          xml.comment! "Optional"
          xml.Zusatzdaten { xml.Geburtsdatum l(user.date_of_birth) } if user.date_of_birth.present?
        end
      end
      xml.comment! "Optional"
      xml.Bemerkungen do
        xml.comment! "Optional max 2 (lets hope there are not too many flags)"
        Notice.details.each do |flag|
          if notice.send(flag)
            xml.Bemerkung t(flag, scope: "activerecord.attributes.notice.flags")
          end
        end
      end
      xml.comment! "Optional"
      xml.Falldaten do
        xml.comment! "Optional"
        xml.Fahrzeug do
          xml.comment! "Optional"
          xml.Nationalitaet "D"
          xml.comment! "Optional"
          xml.Verkehrsbeteiligung "Führer des PKW"
          xml.comment! "Optional"
          xml.VerkehrsbeteiligungKurzform "1D"
          xml.comment! "Optional"
          xml.Fabrikat notice.brand
          xml.comment! "Optional"
          xml.Kennzeichen notice.registration
          xml.comment! "Optional"
          xml.Farbe color_name(notice.color.presence)
        end
        if notice.note.present?
          xml.comment! "Optional"
          xml.NotizAussendienst notice.note
        end
        xml.comment! "Required"
        xml.Tattag do
          xml.comment! "Required"
          xml.Von l(notice.start_date, format: :date)
          xml.comment! "Optional"
          xml.Bis l(notice.end_date, format: :date)
        end
        xml.comment! "Required"
        xml.Tatzeit do
          xml.comment! "Required"
          xml.Von l(notice.start_date, format: :longtime)
          xml.comment! "Optional"
          xml.Bis l(notice.end_date, format: :longtime)
        end
      end
      xml.comment! "Required"
      xml.Tatbestaende do
        xml.comment! "Multiple"
        xml.Tatbestand do
          xml.comment! "Optional (BKAT)"
          xml.Texttyp "9"
          xml.comment! "Required"
          xml.Tatbestandsnummer notice.tbnr
        end
      end
      xml.comment! "Optional"
      xml.Bilder do
        notice.photos.each do |photo|
          xml.comment! "Multiple"
          xml.Bild Inhalt: "Gesamtbild", Dateiname: photo.key
        end
      end
      xml.comment! "Optional"
      xml.Beweise do
        xml.comment! "Optional (0-2)"
        xml.Beweis "Zeugen/Zeuge, Foto"
      end
      xml.comment! "Optional"
      xml.Tatorte do
        xml.comment! "Optional (0-3)"
        xml.Tatort notice.location_and_address
      end
      xml.comment! "Optional"
      xml.Historie do
        xml.comment! "Multiple"
        xml.Eintrag Typ: "Posteingang", Beschreibung: "Privatanzeige", Status: "ausgeführt", Datum: l(now, format: :date), Uhrzeit: l(now, format: :longtime) do
          xml.comment! "Optional"
          xml.Dokumente do
            xml.comment! "Multiple"
            files.each do |file|
              xml.Dokument Dateiname: file
            end
          end
        end
      end
    end
  end
end
