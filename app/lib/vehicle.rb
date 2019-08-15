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

  def self.brands
    cars.map { |entry| entry['brand'] }.sort
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
      'Parken auf Radfahrstreifen (Verkehrszeichen 237)',
      'Parken auf Fahrradschutzstreifen (Gestrichelte Linie)',
      'Parken auf dem Gehweg',
      'Parken im Halteverbot',
      'Parken im eingeschränkten Halteverbot',
      'Parken auf Sperrflächen',
      'Parken auf Grünflächen',
      'Parken bis zu zehn Meter vor Lichtzeichen',
      'Parken auf dem Fußgängerüberweg sowie 5 Meter davor und dahinter',
      'Parken im Kreuzungs-/Einmündungsbereich sowie 5 Meter davor und dahinter',
      'Parken vor abgesenkten Bordsteinen',
      'Parken vor Grundstücksein- und -ausfahrten',
      'Parken auf schmalen Straßen auch gegenüber von Grundstücksein- und -ausfahrten',
      'Parken an Haltestellen (Verkehrszeichen 224) sowie 15 Meter davor und dahinter',
      'Parken auf der Busspur',
      'Parken im Kreisverkehr',
      'Parken in Fußgängerzonen',
      'Parken im verkehrsberuhigten Bereich',
      'Parken auf dem Behindertenparkplatz',
      'Parken in zweiter Reihe',
      'Parken vor Feuerwehrzufahrten',
      'Parken vor und hinter Bahnübergängen mit Andreaskreuz',
      'Parken auf Straßen mit durchgezogener Linie',
      'Parken an Engstellen, wenn weniger als 3 Meter verbleiben würden',
      'Parken im Bereich von Verkehrs- bzw. Durchfahrtsverboten (Verkehrszeichen 250, 252, 253)',
    ]
  end
end
