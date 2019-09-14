class Vehicle
  def self.data
    @data ||= {}
    @data[:cars] ||= JSON.load(Rails.root.join('config/data/cars.json'))
    @data[:plates] ||= JSON.load(Rails.root.join('config/data/plates.json'))
    @data
  end

  def self.cars
    data[:cars]
  end

  def self.plates
    data[:plates]
  end

  def self.plate?(text)
    text = text.strip.gsub(/\W+/,'-')
    if text =~ plate_regex
      "#{$1} #{$2} #{$3}"
    elsif text =~ relaxed_plate_regex
      "#{$1}#{$2}#{$3}"
    end
  end

  def self.plate_regex
    @plate_regex ||= Regexp.new("^(#{Vehicle.plates.keys.join('|')})-([A-Z]{1,3})-(\\d{1,4})$")
  end

  def self.relaxed_plate_regex
    @relaxed_plate_regex ||= Regexp.new("^(#{Vehicle.plates.keys.join('|')})([A-Z]{1,3})-(\\d{1,4})$")
  end

  def self.brand?(text)
    text = text.strip.downcase
    res = cars.find { |entry| text.match?(entry['brand'].strip.downcase) }
    return res['brand'] if res.present?

    res = cars.find do |entry|
      (entry['aliases'] || []).find { |ali| text.match?(ali.strip.downcase) }
    end
    return res['brand'] if res.present?

    res = cars.find do |entry|
      entry['models'].find { |model| model =~ /\D+/ && text == model.strip.downcase }
    end
    return res['brand'] if res.present?
  end

  def self.brands
    (car_brands + truck_brands).sort
  end

  def self.car_brands
    cars.map { |entry| entry['brand'] }
  end

  def self.truck_brands
    [
      'MAN',
      'Iveco',
      'CANIA',
      'DAF',
    ]
  end

  def self.models(brand)
    cars.find { |entry| entry['brand'] == brand }.dig('models')
  end

  def self.colors
    @colors ||= [
      'beige',
      'blue',
      'brown',
      'yellow',
      'grey',
      'green',
      'red',
      'black',
      'silver',
      'violet',
      'white',
      'orange',
      'gold',
    ]
  end

  def self.kinds
    @kinds ||= [
      'PKW',
      'LKW',
      'Motorrad',
    ]
  end

  def self.charges
    @charges = [
      'Parken auf einem unbeschilderten Radweg',
      'Parken auf einem Fußgängerüberweg',
      'Parken auf einem Radweg (Zeichen 237)',
      'Parken auf einem Geh- und Radweg (Zeichen 240/241)',
      'Parken auf einer Fahrradstraße (Zeichen 244.1/244.2)',
      'Parken verbotswidrig auf einem Schutzstreifen für den Radverkehr (Zeichen 340)',
      'Parken verbotswidrig auf einem Gehweg',
      'Parken in einem verkehrsberuhigten Bereich (Zeichen 325.1, 325.2) verbotswidrig außerhalb der zum Parken gekennzeichneten Flächen',
      'Parken in einem Fußgängerbereich, der durch Zeichen 239/242.1, 242.2/250) gesperrt war',
      'Parken in einem Abstand von weniger als 5 Meter vor einem Fußgängerüberweg',
      'Parken weniger als 5 Meter vor/hinter der Kreuzung/Einmündung',
      'Parken im absolutem Haltverbot (Zeichen 283)',
      'Parken unzulässig im eingeschränkten Haltverbot (Zeichen 286)',
      'Parken unzulässig auf einer Sperrfläche (Zeichen 298)',
      'Parken an einer engen/unübersichtlichen Straßenstelle',
      'Parken im Bereich einer scharfen Kurve',
      'Parken unzulässig in der zweiten Reihe',
      'Parken vor oder in einer amtlich gekennzeichneten Feuerwehrzufahrt',
      'Parken verbotswidrig und verhinderten dadurch die Benutzung gekennzeichneter Parkflächen',
      'Parken im Bereich einer Grundstückseinfahrt bzw. -ausfahrt',
      'Parken auf einer schmalen Fahrbahn gegenüber einer Grundstückseinfahrt/Grundstücks-ausfahrt',
      'Parken vor einer Bordsteinabsenkung',
      'Parken verbotswidrig auf der linken Fahrbahnseite/dem linken Seitenstreifen',
      'Parken nicht am rechten Fahrbahnrand',
      'Parken im Fahrraum von Schienenfahrzeugen',
      'Parken links von einer Fahrbahnbegrenzung (Zeichen 295)',
      'Parken auf einem durch Richtungspfeile (Zeichen 297) gekennzeichneten Fahrbahnteil',
      'Parken innerhalb einer Grenzmarkierung (Zeichen 299) für ein Haltverbot',
      'Parken näher als 10 Meter vor einem Andreaskreuz (Zeichen 201)/Zeichen 205 (Vorfahrt gewähren!)/Zeichen 206 (Halt! Vorfahrt gewähren!) und verdeckten dieses',
      'Parken innerhalb eines Kreisverkehrs (Zeichen 215)',
      'Parken in einem Abstand von weniger als 15 Metern von einem Haltestellenschild',
      'Parken, obwohl zwischen Ihrem Fahrzeug und der Fahrstreifenbegrenzung (Zeichen 295/296) ein Abstand von weniger als 3 Metern verblieb',
      'Parken innerhalb einer Grenzmarkierung (Zeichen 299) für ein Parkverbot',
      'Parken bei zulässigem Gehwegparken (Zeichen 315) nicht auf dem Gehweg',
      'Parken auf einem gekennzeichneten Behindertenparkplatz',
      'Parken mit Verbrenner vor Elektroladesäule',
    ]
  end
end
