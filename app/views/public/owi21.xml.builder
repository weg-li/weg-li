# frozen_string_literal: true

xml.instruct!

xml.Datenstrom "xmlns" => "http://www.owi21.de", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xsi:schemaLocation" => "http://www.owi21.de/schemas/xowi_bestand_1.1.xsd" do
  xml.Bestaende do
    xml.Hinzufuegen do
      xml.Bestand(
        # dunno
        # GMK="",
        # AZ="",
        # AnwenderNr="",
        # Sachgebiet_Schluessel="",
        # rest
        Gemarkung: notice.city,
        Tatort: notice.full_location,
        Tattag: notice.start_date.strftime("%Y-%m-%d"),
        Tatzeit: notice.start_date.strftime("%H:%M"),
        Beweis_Schluessel_1: "1", # rubocop:disable RuboCopNaming/VariableNumber Zeugen mit Ausdruck
        Beweis_Schluessel_2: "4", # rubocop:disable RuboCopNaming/VariableNumber Foto
        Beteiligung_Schluessel: "2", # Halterin/Halter
        Fahrzeugtyp_Schluessel: "D", # PKW
        KFZ_Kennzeichen: notice.registration,
        KFZ_Kennzeichen_Merkmal: "1", # FZV
      ) do
        xml.Tatbestan TBNr: notice.tbnr
        xml.Person(
          PersonenTypId: "10", # Zeuge
          Anrede_Schluessel: "3",
          Vorname: user.first_name,
          Nachname: user.last_name,
          Strasse: user.street,
          Hausnummer: user.house_number,
          PLZ: user.zip,
          Ort: user.city,
        )
        # xml.Entscheidung(Schluessel="111" Typ="0")
        xml.Dokumente Typ: "700", Schluessel: "7" do
          notice.photos.each do |photo|
            xml.Dokument Titel: "Uebersicht", Format: "image/jpeg", Datei: photo.key
          end
        end
      end
    end
  end
end
