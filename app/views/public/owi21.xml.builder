# frozen_string_literal: true

xml.instruct!

xml.Datenstrom "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xsi:noNamespaceSchemaLocation" => "xowi_bestand.xsd" do
  xml.Bestaende do
    xml.Hinzufuegen do
      xml.Bestand(
        Gemarkung: notice.city,
        Tatort: notice.full_location,
        Tattag: notice.start_date.strftime("%Y-%m-%d"),
        Tatzeit: notice.start_date.strftime("%H:%M"),
        Beweis_Schluessel_1: "1",
        Beweis_Schluessel_2: "4",
        Beteiligung_Schluessel: "2",
        Fahrzeugtyp_Schluessel: "D",
        KFZ_Kennzeichen: notice.registration,
        KFZ_Kennzeichen_Merkmal: "1",
      ) do
        xml.Tatbestan TBNr: notice.tbnr
        xml.Person(
          PersonenTypId: "10",
          Anrede_Schluessel: "3",
          Vorname: user.first_name,
          Nachname: user.last_name,
          Strasse: user.street,
          Hausnummer: user.house_number,
          PLZ: user.zip,
          Ort: user.city,
        )
        xml.Dokumente Typ: "700", Schluessel: "7" do
          notice.photos.each do |photo|
            xml.Dokument Titel: "Uebersicht", Format: "image/jpeg", Datei: photo.key
          end
        end
      end
    end
  end
end
