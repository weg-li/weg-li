# frozen_string_literal: true

xml.instruct!

xml.Fall do
  xml.Bilder do
    @notice.photos.each do |photo|
      xml.comment! "Required"
      xml.comment! "Dateiname -> Filename of E-Mail Attachment Image"
      xml.comment! "Length -> byte_size of Image"
      xml.Bild Length: photo.byte_size, Dateiname: photo.key
    end
  end
  xml.Beteiligte do
    xml.Beteiligter Funktion: "keine", Typ: "Anzeigenerstatter" do
      xml.Kontakt do
        xml.Anschrift do
          xml.comment! "Default is '-' weg.li does use salutations"
          xml.Anrede "-"
          xml.comment! "Required"
          xml.Vorname @user.first_name
          xml.comment! "Required"
          xml.Name @user.last_name
          xml.comment! "Required"
          xml.Strasse @user.street_without_housenumber
          xml.comment! "Required"
          xml.Hausnummer @user.housenumber
          xml.comment! "Optional"
          xml.Adresszusatz @user.appendix
          xml.comment! "Required"
          xml.PLZ @user.zip
          xml.comment! "Required"
          xml.Ort @user.city
          xml.comment! "Default is 'D' weg.li permits DE only"
          xml.Landeskennzeichen "D"
        end
        xml.comment! "Required"
        xml.EMail @user.email
        xml.comment! "Optional"
        xml.Telefon @user.phone
        xml.comment! "Optional"
        xml.Zusatzdaten { xml.Geburtsdatum @user.date_of_birth }
      end
    end
  end
  xml.Bemerkungen do
    xml.comment! "Optional"
    xml.Bemerkung @notice.note if @notice.note
    Notice.details.each do |flag|
      if @notice.send(flag)
        xml.comment! "Optional"
        xml.Bemerkung t(flag, scope: "activerecord.attributes.notice.flags")
      end
    end
    xml.comment! "Required"
    xml.Bemerkung @notice.wegli_email
  end
  xml.Falldaten do
    xml.Fahrzeug do
      xml.comment! "Default is 'D' weg.li permits DE only"
      xml.Nationalitaet "D"
      xml.comment! "Required"
      xml.comment! "Possible values: #{Vehicle.colors.map { |color| color_name(color) }.join(',')}"
      xml.comment! "List is not updated"
      xml.Farbe color_name(@notice.color.presence)
      xml.comment! "Required"
      xml.comment! "Possible values: #{Vehicle.brands.join(',')}"
      xml.comment! "List is updated"
      xml.Fabrikat @notice.brand
      xml.comment! "Required"
      xml.Kennzeichen @notice.registration
      xml.comment! "Default is '00'"
      xml.Kennzeichenart "00"
    end
    xml.comment! "Required"
    xml.Tattag do
      xml.Von l(@notice.date, format: :date)
      xml.Bis l(@notice.end_date, format: :date)
    end
    xml.comment! "Required"
    xml.Tatzeit do
      xml.Von l(@notice.date, format: :time)
      xml.Bis l(@notice.end_date, format: :time)
    end
  end
  xml.comment! "Required"
  xml.Zeuge { xml.Zeilen { xml.Zeile @user.name } }
  xml.Beweise { xml.Beweis "Zeugin/Zeuge, Fotos" }
  xml.Tatdaten do
    xml.Vorwurf do
      xml.comment! "Required"
      xml.Tatbestandsnummer @notice.tbnr
      xml.comment! "Required"
      xml.VorwurfText @notice.charge
      xml.comment! "Required"
      xml.MitBehinderung @notice.standard? ? 0 : 1
    end
  end
  xml.Tatorte do
    xml.comment! "Required"
    xml.Tatort @notice.location_and_address
    xml.comment! "Required"
    xml.comment! "Geocoordinates"
    xml.Latitude @notice.latitude
    xml.Longitude @notice.longitude
  end
end
