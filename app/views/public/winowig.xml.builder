# frozen_string_literal: true

xml.instruct!

xml.OWIGMDEData Version: "1" do
  xml.Header Herkunft: "weg.li", Sachbearbeitername: "Admin"
  xml.Mandant do
    xml.Fall FallArt: "VOWI", GPS: "#{notice.latitude};#{notice.longitude}" do
      xml.Beteiligte do
        xml.Beteiligter Funktion: "keine", Typ: "Anzeigenerstatter" do
          xml.Kontakt do
            xml.Anschrift do
              xml.comment! "Default is '-' weg.li does use salutations"
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
            xml.Telefon user.phone
            xml.comment! "Optional"
            xml.Zusatzdaten { xml.Geburtsdatum user.date_of_birth }
          end
        end
      end
      xml.Bemerkungen do
        xml.comment! "Optional"
        xml.Bemerkung notice.note if notice.note
        Notice.details.each do |flag|
          if notice.send(flag)
            xml.comment! "Optional"
            xml.Bemerkung t(flag, scope: "activerecord.attributes.notice.flags")
          end
        end
        xml.comment! "Required"
        xml.Bemerkung notice.wegli_email
      end
      xml.Falldaten do
        xml.Fahrzeug do
          xml.Nationalitaet "D"
          xml.Verkehrsbeteiligung "Führer/Halter des PKW"
          xml.Fabrikat notice.brand
          xml.Kennzeichen notice.registration
          xml.Farbe color_name(notice.color.presence)
        end
        xml.Tattag do
          xml.Von l(notice.start_date, format: :date)
          xml.Bis l(notice.end_date, format: :date)
        end
        xml.Tatzeit do
          xml.Von l(notice.start_date, format: :longtime)
          xml.Bis l(notice.end_date, format: :longtime)
        end
      end
      xml.Tatbestaende do
        xml.Tatbestand do
          xml.Texttyp "9"
          xml.Tatbestandsnummer notice.tbnr
          xml.VorwurfText notice.charge.description
        end
      end
      xml.Bilder do
        notice.photos.each do |photo|
          xml.Bild Inhalt: "Gesamtbild", Dateiname: photo.key
        end
      end
      xml.Beweise do
        xml.Beweis "Zeugen/Zeuge, Foto"
      end
      xml.Zeuge { xml.Zeilen { xml.Zeile user.name } }
      xml.Tatorte do
        xml.Tatort notice.full_address
        xml.Tatort notice.location if notice.location.present?
      end
      xml.Historie do
        xml.Eintrag Typ: "Posteingang", Beschreibung: "Privatanzeige", Status: "ausgeführt", Datum: l(now, format: :date), Uhrzeit: l(now, format: :longtime) do
          xml.Dokumente do
            files.each do |file|
              xml.Dokument Dateiname: file
            end
          end
        end
      end
    end
  end
end
