class CompareJob < ApplicationJob
  def perform(notice)
    Rails.logger.info("comparing #{notice.id}")

    api = OpenapiClient::AnalyzeApi.new
    api.api_client.config = api_config

    image_upload_response = api.analyze_image_upload_get(quantity: notice.photos.size)
    notice.photos.each_with_index do |photo, i|
      url = image_upload_response.google_cloud_urls[i]

      photo.service.download_file(photo.key) do |file|
        header = { 'Content-Type' => 'image/jpeg' }
        res = HTTPClient.new.put(url, header: header, body: file)
        raise res.body unless res.ok?
      end

      data_set = notice.data_sets.google_vision.find_by(keyable: photo)
      notify("for notice #{notice.id} google found #{data_set.registrations} #{data_set.brands} #{data_set.colors}") if data_set
    end
    location = OpenapiClient::Location.new(latitude: notice.latitude, longitude: notice.longitude)

    request = {
      user_id: notice.user.project_user_id,
      time: notice.date.to_i,
      location: location
    }

    api.api_client.config.access_token = notice.user.project_access_token
    suggestions = api.analyze_data_post(request)
    suggestions.first(3).each_with_index do |suggestion, i|
      notify("for notice #{notice.id} the project suggests violation #{i} #{VIOLATION_TYPES[suggestion.violation_type]}")
    end

    response = api.analyze_image_image_token_get(image_upload_response.token)
    notify("for notice #{notice.id} the project found #{response.suggestions}")
  end

  private

  def api_config
    config = OpenapiClient::Configuration.new
    config.host = 'https://europe-west3-wegli-296209.cloudfunctions.net/'
    config.base_path = 'api'
  	config.debugging = true
    config
  end

  VIOLATION_TYPES = [
    'Parken auf einem unbeschilderten Radweg',
    'Parken auf einem Fußgängerüberweg',
    'Parken auf einem Radweg (Zeichen 237)',
    'Parken auf einem Geh- und Radweg (Zeichen 240/241)',
    'Parken auf einer Fahrradstraße (Zeichen 244.1/244.2)',
    'Parken verbotswidrig auf einem Schutzstreifen für den Radverkehr (Zeichen 340)',
    'Parken verbotswidrig auf einem Gehweg',
    'Parken in einem verkehrsberuhigten Bereich (Zeichen 325.1, 325.2) verbotswidrig außerhalb der zum Parken gekennzeichneten Flächen',
    'Parken in einem Fußgängerbereich, der (durch Zeichen 239/242.1, 242.2/250) gesperrt war',
    'Parken in einem Abstand von weniger als 5 Meter vor einem Fußgängerüberweg',
    'Parken weniger als 8 Meter vor der Kreuzung/Einmündung, obwohl in Fahrtrichtung rechts neben der Fahrbahn ein Radweg baulich angelegt ist',
    'Parken weniger als 5 Meter vor/hinter der Kreuzung/Einmündung',
    'Parken im absolutem Haltverbot (Zeichen 283)',
    'Parken unzulässig im eingeschränkten Haltverbot (Zeichen 286)',
    'Parken unzulässig auf einer Sperrfläche (Zeichen 298)',
    'Parken an einer engen/unübersichtlichen Straßenstelle',
    'Parken im Bereich einer scharfen Kurve',
    'Parken unzulässig in der zweiten Reihe',
    'Parken näher als 10 Meter vor einem Lichtzeichen',
    'Parken vor oder in einer amtlich gekennzeichneten Feuerwehrzufahrt',
    'Parken verbotswidrig im Bereich eines Taxenstandes (Zeichen 229)',
    'Parken verbotswidrig und verhinderten dadurch die Benutzung gekennzeichneter Parkflächen',
    'Parken im Bereich einer Grundstückseinfahrt bzw. -ausfahrt',
    'Parken auf einer schmalen Fahrbahn gegenüber einer Grundstückseinfahrt/Grundstücks-ausfahrt',
    'Parken vor einer Bordsteinabsenkung',
    'Parken verbotswidrig auf der linken Fahrbahnseite/dem linken Seitenstreifen',
    'Parken nicht am rechten Fahrbahnrand',
    'Parken im Fahrraum von Schienenfahrzeugen',
    'Parken links von einer Fahrbahnbegrenzung (Zeichen 295)',
    'Parken in einem Verkehrsbereich, der (durch Zeichen 250/251/253/255/260) gesperrt war',
    'Parken auf einem durch Richtungspfeile (Zeichen 297) gekennzeichneten Fahrbahnteil',
    'Parken innerhalb einer Grenzmarkierung (Zeichen 299) für ein Haltverbot',
    'Parken näher als 10 Meter vor einem Andreaskreuz (Zeichen 201)/Zeichen 205 (Vorfahrt gewähren!)/Zeichen 206 (Halt! Vorfahrt gewähren!) und verdeckten dieses',
    'Parken innerhalb eines Kreisverkehrs (Zeichen 215)',
    'Parken in einem Abstand von weniger als 15 Metern von einem Haltestellenschild',
    'Parken, obwohl zwischen Ihrem Fahrzeug und der Fahrstreifenbegrenzung (Zeichen 295/296) ein Abstand von weniger als 3 Metern verblieb',
    'Parken innerhalb einer Grenzmarkierung (Zeichen 299) für ein Parkverbot',
    'Parken bei zulässigem Gehwegparken (Zeichen 315) nicht auf dem Gehweg',
    'Parken auf einem Sonderfahrstreifen für Omnibusse des Linienverkehrs (Zeichen 245)',
    'Parken auf einem gekennzeichneten Behindertenparkplatz',
    'Parken mit Verbrenner vor Elektroladesäule',
    'Parken auf einer Grünfläche',
    'Parken auf einer Baumscheibe',
    'Parken in der Einbahnstraße entgegen der Fahrtrichtung',
    'Sonstiges Parkvergehen (siehe Hinweise)',
  ]
end
