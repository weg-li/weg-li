user = @notice.user
xml.instruct!

# <?xml version="1.0" encoding="ISO-8859-1" ?>
# <Datenstrom xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
# xsi:noNamespaceSchemaLocation="http://www.owi21.de/schemas/xsd/xowi_bestand.xsd"> <Bestaende>
# <Hinzufuegen>
# <Bestand GMK="06699999"
# AnwenderNr="998"
# Kostenstelle="998"
# AZ="998123456"
# Sachgebiet_Schluessel="4"
# Gemarkung="Testgemeinde" Tatort="OT Unterdorf, Teststraße 12, stadteinwärts" Tattag="2008-09-12" Tatzeit="12:34"
#    ekom21-KGRZ Hessen Seite 39 von 52 08.11.2019
#  xOwi-Bestand, Version 1.1
#  Beweis_Schluessel_1="1"
# Beweis_Schluessel_2="K"
# Beweis_Schluessel_3="9"
# Beweis_Sonstige="Film/Bild-Nr. 0805018/088"
# Beteiligung_Schluessel="1"
# Betr_Anrede_Schluessel="1"
# Fahrzeugtyp_Schluessel="F" FahrzeugSubtyp_Schluessel="1"
# KFZ_Kennzeichen="HR-DH 262" KFZ_Kennzeichen_Merkmal="1" KFZ_Hersteller="DaimlerBenz">
# <Tatbestand TBNr="123500" />
# <Zeuge Name="Herr Bergmann" Ort="ÖOB Kleinkleckersdorf" /> <Entscheidung Schluessel="111" Typ="0">
# <Dokumente Typ="703" Schluessel="7">
# <Dokument Format="image/jpeg" Datei="Uebersichtsfoto_1.jpg" /> </Dokumente>
# <Dokumente Typ="702" Schluessel="7">
# <Dokument Format="image/jpeg" Datei="Frontfoto_1.jpg" Drucken="1" />
# </Dokumente>
# <Dokumente Typ="704" Schluessel="7">
# <Dokument Format="image/jpeg" Datei="Kennzeichenfoto_1.jpg" /> </Dokumente>
# <Dokumente Typ="705" Schluessel="7">
# <Dokument Format="=" application/pdf " Datei="Messprotokoll_4711_2008-09-12.pdf" />
# </Dokumente>
# <Dokumente Typ="706" Schluessel="7">
# <Dokument Format="=" application/pdf " Datei="Eichschein_Geraet-XYZ_2008-01-29.pdf" /> </Dokumente>
# </Entscheidung>
# </Bestand> </Hinzufuegen>
# </Bestaende> </Datenstrom>

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
          xml.Anrede '-'
					xml.Vorname user.first_name
					xml.Name user.last_name
					xml.Strasse user.street_without_housenumber
					xml.Hausnummer user.housenumber
					xml.Adresszusatz user.appendix
          xml.PLZ user.zip
					xml.Ort user.city
          xml.Landeskennzeichen 'D'
        end
        xml.EMail user.email
        xml.Telefon user.phone
  			xml.Zusatzdaten do
  				xml.Geburtsdatum user.date_of_birth
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
      xml.Zeile user.name
    end
  end
  xml.Beweise do
    xml.Beweis 'Zeugin/Zeuge, Fotos'
  end
  xml.Tatdaten do
    xml.Vorwurf do
      xml.Tatbestandsnummer Charge.plain_charges_tbnr(@notice.charge)
      xml.VorwurfText @notice.charge
      xml.MitBehinderung @notice.standard? ? 0 : 1
    end
  end
  xml.Tatorte do
    xml.Tatort @notice.location_and_address
    xml.Latitude @notice.latitude
    xml.Longitude @notice.longitude
  end
end
