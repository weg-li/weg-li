require 'csv'

class Vehicle
  def self.cars
    @cars ||= JSON.load(Rails.root.join('config/data/cars.json'))
  end

  def self.plates
    @plates ||= JSON.load(Rails.root.join('config/data/plates.json'))
  end

  def self.most_often?(matches)
    return nil if matches.blank?

    matches.group_by(&:itself).sort_by { |match, group| group.size }.last[0]
  end

  def self.most_likely?(matches)
    return nil if matches.blank?

    groups = matches.group_by { |key, _| key.gsub(/\W/, '') }.sort_by { |_, group| group.sum { |_, probability| probability }.fdiv(matches.size) }
    best_match = groups.last
    best_match[1].flatten[0]
  end

  def self.plate?(text, prefixes: nil)
    text = normalize(text)

    if prefixes.present? && text =~ plate_regex(prefixes)
      ["#{$1} #{$2} #{$3}#{$4.to_s.gsub('-', ' ')}", 1.2]
    elsif prefixes.present? && text =~ relaxed_plate_regex(prefixes)
      ["#{$1} #{$2} #{$3}#{$4.to_s.gsub('-', ' ')}", 1.1]
    elsif text =~ plate_regex
      ["#{$1} #{$2} #{$3}#{$4.to_s.gsub('-', ' ')}", 1.0]
    elsif text =~ relaxed_plate_regex
      ["#{$1}#{$2} #{$3}#{$4.to_s.gsub('-', ' ')}", 0.8]
    elsif text =~ quirky_mode_plate_regex
      ["#{$1}#{$2} #{$3}#{$4.to_s.gsub('-', ' ')}", 0.5]
    end
  end

  def self.normalize(text)
    return '' if text.blank?

    tokens = "[ •»„.,:;\"'()|_+-]"
    left = Regexp.new("^\\d?#{tokens}+")
    right = Regexp.new("#{tokens}+$")
    middle = Regexp.new("(\\d+)#{tokens}+(\\d+)")
    text.gsub(left, '').gsub(right, '').gsub(middle, '\1\2').gsub(/\W+/,'-')
  end

  def self.plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^(#{prefixes.join('|')})-([A-Z]{1,3})-?(\\d{1,4})(-E)?$")
  end

  def self.relaxed_plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^(#{prefixes.join('|')})O?:?-?([A-Z]{1,3})-?(\\d{1,4})(-E)?$")
  end

  def self.quirky_mode_plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^P?D?C?O?B?(#{prefixes.join('|')})O?:?-?0?([A-Z]{1,3})-?(\\d{1,4})(-E)?$")
  end

  def self.district_for_plate_prefix(text)
    prefixes = normalize(text)[plate_regex, 1]
    plates[prefixes]
  end

  def self.brand?(text)
    res = cars.find do |entry|
      return nil if (entry['falsepositives'] || []).find { |ali| text == ali }
    end

    text = text.strip.downcase

    res = cars.find { |entry| text == entry['brand'].strip.downcase }
    return [res['brand'], 1.0] if res.present?

    res = cars.find do |entry|
      (entry['aliases'] || []).find { |ali| text == ali.strip.downcase }
    end
    return [res['brand'], 1.0] if res.present?

    res = camper_brands.find { |brand| text == brand.strip.downcase }
    return [res, 1.0] if res.present?

    res = truck_brands.find { |brand| text == brand.strip.downcase }
    return [res, 1.0] if res.present?

    res = cars.find { |entry| text.match?(entry['brand'].strip.downcase) }
    return [res['brand'], 0.8] if res.present?

    res = cars.find do |entry|
      entry['models'].find { |model| model =~ /\D{3,}/ && text == model.strip.downcase }
    end
    return [res['brand'], 0.5] if res.present?
  end

  def self.brands
    (car_brands + truck_brands + camper_brands).sort
  end

  def self.car_brands
    cars.map { |entry| entry['brand'] }
  end

  def self.camper_brands
    [
      'Adria',
    ]
  end

  def self.truck_brands
    [
      'MAN',
      'IVECO',
      'SCANIA',
      'DAF',
      'Setra',
    ]
  end

  def self.models(brand)
    cars.find { |entry| entry['brand'] == brand }.dig('models')
  end

  def self.percentage(brand)
    market.dig(brand, 1)
  end

  def self.market
    # https://www.n-tv.de/wirtschaft/VW-bleibt-Marktfuehrer-in-Deutschland-article20883337.html
    @market ||= {
      'Volkswagen' => [10039389, 21.3],
      'Opel' => [4455662, 9.5],
      'Mercedes-Benz' => [4434329, 9.4],
      'Ford' => [3438207, 7.3],
      'Audi' => [3242838, 6.9],
      'BMW' => [3256884, 6.9],
      'Škoda' => [2169706, 4.6],
      'Renault' => [1773013, 3.8],
      'Toyota' => [1302395, 2.8],
      'Fiat' => [1174960, 2.5],
      'Hyundai' => [1195023, 2.5],
      'Seat' => [1154612, 2.5],
      'Peugeot' => [1119914, 2.4],
      'Mazda' => [859054, 1.8],
      'Nissan' => [863144, 1.8],
      'Citroën' => [742167, 1.6],
      'Kia' => [662174, 1.4],
      'Dacia' => [547617, 1.2],
      'Suzuki' => [502393, 1.1],
      'Honda' => [451525, 1.0],
      'Mitsubishi' => [484017, 1.0],
      'Smart' => [474898, 1.0],
      'Volvo' => [489040, 1.0],
      'MINI' => [445226, 0.9],
      'Sonstige' => [415633, 0.9],
      'Porsche' => [313173, 0.7],
      'Chevrolet' => [214604, 0.5],
      'Alfa Romeo' => [119095, 0.3],
      'Subaru' => [123887, 0.3],
      'Daihatsu' => [78619, 0.2],
      'Jaguar' => [73932, 0.2],
      'Jeep' => [112467, 0.2],
      'Land Rover' => [108056, 0.2],
      'Chrysler' => [59001, 0.1],
      'DS' => [33607, 0.1],
      'Lancia' => [28860, 0.1],
      'Lexus' => [27282, 0.1],
      'MG Rover' => [28777, 0.1],
      'Saab' => [44345, 0.1],
    }
  end

  def self.colors
    @colors ||= [
      'beige',
      'blue',
      'brown',
      'yellow',
      'gray',
      'green',
      'red',
      'black',
      'silver',
      'violet',
      'purple',
      'pink',
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

  def self.durations
    @durations ||= [
      ['bis zu 3 Minuten', 1],
      ['länger als 3 Minuten', 3],
      ['länger als 5 Minuten', 5],
      ['länger als 10 Minuten', 10],
      ['länger als 15 Minuten', 15],
      ['länger als 30 Minuten', 30],
      ['länger als 45 Minuten', 45],
      ['länger als 1 Stunde', 60],
      ['länger als 3 Stunden', 180],
    ]
  end
end
