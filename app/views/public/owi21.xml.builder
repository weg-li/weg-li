# frozen_string_literal: true

xml.instruct!

xml.Datenstrom "xmlns" => "http://www.owi21.de", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xsi:schemaLocation" => "http://www.owi21.de/schemas/xowi_bestand_1.1.xsd" do
  xml.Bestaende do
    xml.Hinzufuegen do
      xml.Bestand(
        GMK: notice.district.ags,
        GUID: notice.guid,
        Gemarkung: notice.city,
        Tatort: notice.full_location,
        Tattag: notice.start_date.strftime("%Y-%m-%d"),
        Tatzeit: notice.start_date.strftime("%H:%M"),
        Beweis_Schluessel_1: "1",
        Beweis_Schluessel_2: "4",
        Beteiligung_Schluessel: "2", # Halterin/Halter
        Fahrzeugtyp_Schluessel: "D", # PKW
        KFZ_Kennzeichen: Vehicle.normalize(notice.registration, text_divider: "-"),
        KFZ_Kennzeichen_Merkmal: "1", # FZV
      ) do
        xml.Tatbestand TBNr: notice.tbnr
        xml.Entscheidung(
          Schluessel: "111",
          Typ: "2",
          Datum: now.strftime("%Y-%m-%d"),
        )
        xml.Person(
          PersonenTypId: "10", # Zeuge
          Anrede_Schluessel: "9", # unbestimmt
          Vorname: user.first_name,
          Nachname: user.last_name,
          Strasse: user.street,
          Hausnummer: user.house_number,
          PLZ: user.zip,
          Ort: user.city,
        )
        xml.Dokumente(
          Typ: "700",
          Datum: now.strftime("%Y-%m-%d"),
          Schluessel: "7", # externe Dokumente
        ) do
          notice.photos.each do |photo|
            xml.Dokument(
              Format: "image/jpeg",
              Datei: photo.key,
              SpeicherTyp: "0", # Speicherung auf dem OWI Server
            )
          end
        end
      end
    end
  end
end
