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
    if text.strip.gsub(/\W+/,'-') =~ plate_regex
      "#{$1} #{$2} #{$3}"
    end
  end

  def self.plate_regex
    @plate_regex ||= Regexp.new("^(#{Vehicle.plates.keys.join('|')})-([A-Z]{1,3})-(\\d{1,4})$")
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
      'Parken auf Radweg unbeschildert',
      'Parken auf Radweg beschildert',
      'Parken auf Fahrradschutzstreifen',
      'Parken im Kreuzungs-/Einmündungsbereich sowie 5 Meter davor und dahinter',
      'Parken auf dem Fußgängerüberweg sowie 5 Meter davor und dahinter',
      'Parken im Halteverbot',
      'Parken auf Behindertenparkplatz',
      'Parken auf Sperrfläche',
      'Parken auf Busspur',
      'Fahrzeug blockiert Feuerwehrzufahrt',
      'Fahrzeug blockiert Elektroladesäule',
      'Parken vor Grundstücksein- und -ausfahrten',
      'Parken vor abgesenkten Bordsteinen',
      'Parken vor und hinter Bahnübergängen mit Andreaskreuz (innerorts besteht im 5-Meter-Bereich, außerorts im 50-Meter-Bereich das Parkverbot)',
      'Parken an Haltestellen (Verkehrszeichen 224) sowie 15 Meter davor und dahinter',
      'Parken im Kreisverkehr',
      'Parken in Fußgängerzonen',
      'Parken im Bereich von Verkehrs- bzw. Durchfahrtsverboten (Verkehrszeichen 250, 252, 253)',
      'Parken auf schmalen Straßen, auch gegenüber von Grundstücksein- und -ausfahrten',
      'Parken auf Straßen mit durchgezogener Linie',
      'Parken an Engstellen, wenn weniger als 3 Meter zwischen dem parkenden Fahrzeug und der Fahrstreifenbegrenzung verbleiben würden',
      'Parken im verkehrsberuhigten Bereich außerhalb der ausgewiesenen Parkflächen',
    ]
  end
end
