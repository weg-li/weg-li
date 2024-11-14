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
          xml.Fabrikat notice.brand
          xml.Kennzeichen notice.registration
          xml.Kennzeichenart "00"
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
          xml.Verstossart "8"
        end
      end
      xml.Bilder do
        notice.photos.each do |photo|
          xml.Bild Inhalt: "Gesamtbild", Dateiname: photo.key
        end
      end
      xml.Beweise do
        xml.Beweis "Zeugin/Zeuge"
        xml.Beweis "Foto"
      end
      xml.Zeuge do
        xml.Zeilen do
          xml.Zeile user.name
          xml.Zeile user.full_address
        end
      end
      xml.Tatorte do
        xml.Tatort notice.full_address
        xml.Tatort notice.location if notice.location.present?
        xml.Tatort "(#{notice.latitude},#{notice.longitude})"
      end
    end
  end
end
