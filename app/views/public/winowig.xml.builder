xml.instruct!

xml.Fall do
  xml.Bilder do
    @notice.photos.each do |photo|
      xml.Bild Length: photo.byte_size, Dateiname: photo.key
    end
  end
  xml.Beteiligte do
    xml.Beteiligter Funktion: "keine", Typ: "Anzeigenerstatter" do
      xml.Kontakt do
        xml.Anschrift do
					xml.Vorname @notice.user.first_name
					xml.Name @notice.user.last_name
					xml.Strasse @notice.user.street_without_housenumber
					xml.Hausnummer @notice.user.housenumber
					xml.Adresszusatz @notice.user.appendix
          xml.PLZ @notice.zip
					xml.Ort @notice.city
          xml.Landeskennzeichen 'D'
        end
        xml.EMail @notice.user.email
        xml.Telefon @notice.user.phone
  			xml.Zusatzdaten do
  				xml.Geburtsdatum @notice.user.date_of_birth
  			end
      end
    end
  end
	xml.Bemerkungen do
		xml.Bemerkung @notice.note if @notice.note
    Notice.details.each { |flag| xml.Bemerkung t(flag, scope: "activerecord.attributes.notice.flags") if @notice.send(flag) }
    xml.Bemerkung @notice.wegli_email
	end
  xml.Falldaten do
    xml.Fahrzeug do
      xml.Nationalitaet 'D'
      xml.Farbe I18n.t(@notice.color.presence, scope: "activerecord.attributes.notice.colors", default: '-')
      xml.Fabrikat @notice.brand
      xml.Kennzeichen @notice.registration
      xml.Kennzeichenart '00'
    end
    xml.Tattag do
      xml.Von l(@notice.date, format: :date)
      xml.Bis l(@notice.date + @notice.duration.minutes, format: :date)
    end
    xml.Tatzeit do
      xml.Von l(@notice.date, format: :time)
      xml.Bis l(@notice.date + @notice.duration.minutes, format: :time)
    end
  end
  xml.Zeuge do
    xml.Zeilen do
      xml.Zeile @notice.user.name
    end
  end
  xml.Beweise do
    xml.Beweis 'Zeugin/Zeuge, Fotos'
  end
  xml.Tatdaten do
    xml.Vorwurf do
      xml.VorwurfId Vehicle.charges.index(@notice.charge) + 1
      xml.VorwurfText @notice.charge
      xml.MitBehinderung @notice.standard? ? 0 : 1
    end
  end
  xml.Tatorte do
    xml.Tatort @notice.street
    xml.Latitude @notice.latitude
    xml.Longitude @notice.longitude
  end
end
