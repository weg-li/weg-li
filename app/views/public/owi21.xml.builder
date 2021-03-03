user = @notice.user
xml.instruct!(:xml, encoding: "ISO-8859-1")

xml.Datenstrom("xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xsi:noNamespaceSchemaLocation" => "http://www.owi21.de/schemas/xsd/xowi_bestand.xsd") do
  xml.Bestaende do
    xml.Hinzufuegen do
      xml.Bestand(
        # GMK: "06699999",
        # AnwenderNr: "998",
        # Kostenstelle: "998",
        # AZ: "998123456",
        # Sachgebiet_Schluessel: "4",
        # Gemarkung: "Testgemeinde",
        Tatort: @notice.location_and_address,
        # Tattag: "2008-09-12",
        Tattag: l(@notice.date, format: :date),
        # Tatzeit: "12:34",
        Tatzeit: l(@notice.date, format: :time),
        # Beweis_Schluessel_1: "1",
        # Beweis_Schluessel_2: "K",
        # Beweis_Schluessel_3: "9",
        # Beweis_Sonstige: "Film/Bild-Nr. 0805018/088",
        # Beteiligung_Schluessel: "1",
        # Betr_Anrede_Schluessel: "1",
        # Fahrzeugtyp_Schluessel: "F",
        # FahrzeugSubtyp_Schluessel: "1",
        KFZ_Kennzeichen: @notice.registration,
        KFZ_Kennzeichen_Merkmal: "1",
        KFZ_Hersteller: @notice.brand,
      )
      xml.Tatbestand(TBNr: Charge.plain_charges_tbnr(@notice.charge))
      xml.Zeuge(Name: "Herr Bergmann", Ort: "ÖOB Kleinkleckersdorf")
      xml.Entscheidung(Schluessel: "111", Typ: "0") do
        xml.Dokumente(Typ: "703", Schluessel: "7") do
          @notice.photos.each do |photo|
            xml.Dokument(Format: "image/jpeg", Datei: photo.key)
          end
        end
      end
    end
  end
end
