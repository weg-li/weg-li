# frozen_string_literal: true

xml.instruct!

xml.OWIGMDEData Version: "1" do
  xml.Header Herkunft: "WinowigMobil-Export", Sachbearbeitername: "Admin"
  xml.Mandant do
    xml.Fall FallArt: "VOWI" do
      xml.Falldaten do
        xml.Fahrzeug do
          xml.Nationalitaet "D"
          xml.Verkehrsbeteiligung "Führer/Halter des PKW"
          xml.Fabrikat "Volkswagen"
          xml.Kennzeichen "RW-WO 888"
          xml.Kennzeichenart "00"
          xml.Kennzeichenzusatz "E"
        end
        xml.Aktenzeichen "239003626"
        xml.Kassenzeichen "30003621"
        xml.Tattag do
          xml.Von "29.05.2024"
        end
        xml.Tatzeit do
          xml.Von "09:05:00"
          xml.Bis "09:11:00"
        end
        xml.Ventilstellung do
          xml.Text "links V8/H7"
        end
      end
      xml.Tatbestaende do
        xml.Tatbestand do
          xml.Texttyp "9"
          xml.Tatbestandsnummer "113300"
          xml.Verstossart "8"
          xml.Konkretisierungen ";314;"
          xml.Tatdaten do
            xml.ErsteKontrollzeit "09:05:00"
            xml.Ventilstellung do
              xml.Vorne "8"
              xml.Hinten "7"
            end
            xml.Wagenseite "links"
          end
          xml.BETOriginaltext "Sie parkten bei Zeichen xml.314/315>, ohne die durch Zusatzzeichen vorgeschriebene Parkscheibe (Bild 318) von au�en gut lesbar im oder am Fahrzeug angebracht zu haben.
� 13 Abs. 1, 2, � 49 StVO; � 24 Abs. 1, 3 Nr. 5 StVG; 63.1 BKat"
        end
      end
      xml.Bilder do
        xml.Bild Inhalt: "Gesamtbild", Dateiname: "20240529090933166101.jpg"
        xml.Bild Inhalt: "Fahrerbild", Dateiname: "20240529090946168101.jpg"
        xml.Bild Inhalt: "KFZKennzeichenbild", Dateiname: "20240529090955169101.jpg"
        xml.Bild Inhalt: "Rotlichtbild", Dateiname: "20240529091038172101.jpg"
        xml.Bild Inhalt: "Zusatzbild1", Dateiname: "20240529091004170101.jpg"
        xml.Bild Inhalt: "Zusatzbild2", Dateiname: "20240529091021171101.jpg"
      end
      xml.Beweise do
        xml.Beweis "Foto"
      end
      xml.Zeuge do
        xml.Zeilen do
          xml.Zeile "02; 10"
          xml.Zeile "Müller, Henry"
        end
      end
      xml.Tatorte do
        xml.Tatort "Musterstadt"
        xml.Tatort "August-Bebel-Platz, auf dem PPL"
      end
    end
  end
end

# xml.Fall do
#   xml.Bilder do
#     notice.photos.each do |photo|
#       xml.comment! "Required"
#       xml.comment! "Dateiname -> Filename of E-Mail Attachment Image"
#       xml.comment! "Length -> byte_size of Image"
#       xml.Bild Length: photo.byte_size, Dateiname: photo.key
#     end
#   end
#   xml.Beteiligte do
#     xml.Beteiligter Funktion: "keine", Typ: "Anzeigenerstatter" do
#       xml.Kontakt do
#         xml.Anschrift do
#           xml.comment! "Default is '-' weg.li does use salutations"
#           xml.Anrede "-"
#           xml.comment! "Required"
#           xml.Vorname user.first_name
#           xml.comment! "Required"
#           xml.Name user.last_name
#           xml.comment! "Required"
#           xml.Strasse user.street_without_housenumber
#           xml.comment! "Required"
#           xml.Hausnummer user.housenumber
#           xml.comment! "Optional"
#           xml.Adresszusatz user.appendix
#           xml.comment! "Required"
#           xml.PLZ user.zip
#           xml.comment! "Required"
#           xml.Ort user.city
#           xml.comment! "Default is 'D' weg.li permits DE only"
#           xml.Landeskennzeichen "D"
#         end
#         xml.comment! "Required"
#         xml.EMail user.email
#         xml.comment! "Optional"
#         xml.Telefon user.phone
#         xml.comment! "Optional"
#         xml.Zusatzdaten { xml.Geburtsdatum user.date_of_birth }
#       end
#     end
#   end
#   xml.Bemerkungen do
#     xml.comment! "Optional"
#     xml.Bemerkung notice.note if notice.note
#     Notice.details.each do |flag|
#       if notice.send(flag)
#         xml.comment! "Optional"
#         xml.Bemerkung t(flag, scope: "activerecord.attributes.notice.flags")
#       end
#     end
#     xml.comment! "Required"
#     xml.Bemerkung notice.wegli_email
#   end
#   xml.Falldaten do
#     xml.Fahrzeug do
#       xml.comment! "Default is 'D' weg.li permits DE only"
#       xml.Nationalitaet "D"
#       xml.comment! "Required"
#       xml.comment! "Possible values: #{Vehicle.colors.map { |color| color_name(color) }.join(',')}"
#       xml.comment! "List is not updated"
#       xml.Farbe color_name(notice.color.presence)
#       xml.comment! "Required"
#       xml.comment! "Possible values: #{Vehicle.brands.join(',')}"
#       xml.comment! "List is updated"
#       xml.Fabrikat notice.brand
#       xml.comment! "Required"
#       xml.Kennzeichen notice.registration
#       xml.comment! "Default is '00'"
#       xml.Kennzeichenart "00"
#     end
#     xml.comment! "Required"
#     xml.Tattag do
#       xml.Von l(notice.start_date, format: :date)
#       xml.Bis l(notice.end_date, format: :date)
#     end
#     xml.comment! "Required"
#     xml.Tatzeit do
#       xml.Von l(notice.start_date, format: :time)
#       xml.Bis l(notice.end_date, format: :time)
#     end
#   end
#   xml.comment! "Required"
#   xml.Zeuge { xml.Zeilen { xml.Zeile user.name } }
#   xml.Beweise { xml.Beweis "Zeugin/Zeuge, Fotos" }
#   xml.Tatdaten do
#     xml.Vorwurf do
#       xml.comment! "Required"
#       xml.Tatbestandsnummer notice.tbnr
#       xml.comment! "Required"
#       xml.VorwurfText notice.charge.description
#     end
#   end
#   xml.Tatorte do
#     xml.comment! "Required"
#     xml.Tatort notice.location_and_address
#     xml.comment! "Required"
#     xml.comment! "Geocoordinates"
#     xml.Latitude notice.latitude
#     xml.Longitude notice.longitude
#   end
# end
