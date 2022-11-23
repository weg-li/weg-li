# frozen_string_literal: true

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

    matches.group_by(&:itself).max_by { |_match, group| group.size }[0]
  end

  def self.by_likelyhood(matches)
    return [] if matches.blank?

    groups = matches.group_by { |key, _| key.gsub(/\W/, '') }
    groups = groups.sort_by { |_, group| group.sum { |_, probability| probability }.fdiv(matches.size) }
    groups.map { |match| match[1].flatten[0] }.reverse
  end

  def self.most_likely?(matches)
    by_likelyhood(matches).first
  end

  def self.plate?(text, prefixes: nil)
    text = normalize(text)

    if prefixes.present? && text =~ plate_regex(prefixes)
      ["#{$1} #{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 1.2]
    elsif prefixes.present? && text =~ relaxed_plate_regex(prefixes)
      ["#{$1} #{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 1.1]
    elsif text =~ plate_regex
      ["#{$1} #{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 1.0]
    elsif text =~ relaxed_plate_regex
      ["#{$1}#{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 0.8]
    elsif text =~ quirky_mode_plate_regex
      ["#{$1}#{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 0.5]
    end
  end

  def self.normalize(text)
    return '' if text.blank?

    text.gsub(/^([^A-Z,ÖÄÜ])+/, '').gsub(/([^E,0-9])+$/, '').gsub(/([^A-Z,ÖÄÜ0-9])+/, '-')
  end

  def self.plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^(#{prefixes.join('|')})-([A-Z]{1,3})-?(\\d{1,4})(-?E)?$")
  end

  def self.relaxed_plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^(#{prefixes.join('|')})O?:?-?([A-Z]{1,3})-?(\\d{1,4})(-?E)?$")
  end

  def self.quirky_mode_plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^P?D?C?O?B?(#{prefixes.join('|')})O?:?-?0?([A-Z]{1,3})-?(\\d{1,4})(-?E)?$")
  end

  def self.district_for_plate_prefix(text)
    prefixes = normalize(text)[plate_regex, 1]
    plates[prefixes]
  end

  def self.brand?(text)
    cars.find do |entry|
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

  def self.brand_options
    @brand_options ||= {
      'PKW' => Vehicle.cars.map { |entry| ["#{entry['brand']} #{" (#{entry['aliases'].join(', ')})" if entry['aliases'].present?}", entry['brand']] }.sort,
      'LKW' => Vehicle.truck_brands.sort,
      'Camper' => Vehicle.camper_brands.sort,
    }
  end

  def self.brands
    (car_brands + truck_brands + camper_brands).sort
  end

  def self.car_brands
    cars.map { |entry| entry['brand'] }
  end

  def self.camper_brands
    %w[
      Adria
      Hymer
    ]
  end

  def self.truck_brands
    %w[
      MAN
      IVECO
      SCANIA
      DAF
      Setra
    ]
  end

  def self.models(brand)
    cars.find { |entry| entry['brand'] == brand }['models']
  end

  def self.percentage(brand)
    market.dig(brand, 1)
  end

  def self.market
    # https://www.n-tv.de/wirtschaft/VW-bleibt-Marktfuehrer-in-Deutschland-article20883337.html
    @market ||= {
      'Volkswagen' => [10_039_389, 21.3],
      'Opel' => [4_455_662, 9.5],
      'Mercedes-Benz' => [4_434_329, 9.4],
      'Ford' => [3_438_207, 7.3],
      'Audi' => [3_242_838, 6.9],
      'BMW' => [3_256_884, 6.9],
      'Škoda' => [2_169_706, 4.6],
      'Renault' => [1_773_013, 3.8],
      'Toyota' => [1_302_395, 2.8],
      'Fiat' => [1_174_960, 2.5],
      'Hyundai' => [1_195_023, 2.5],
      'Seat' => [1_154_612, 2.5],
      'Peugeot' => [1_119_914, 2.4],
      'Mazda' => [859_054, 1.8],
      'Nissan' => [863_144, 1.8],
      'Citroën' => [742_167, 1.6],
      'Kia' => [662_174, 1.4],
      'Dacia' => [547_617, 1.2],
      'Suzuki' => [502_393, 1.1],
      'Honda' => [451_525, 1.0],
      'Mitsubishi' => [484_017, 1.0],
      'Smart' => [474_898, 1.0],
      'Volvo' => [489_040, 1.0],
      'MINI' => [445_226, 0.9],
      'Sonstige' => [415_633, 0.9],
      'Porsche' => [313_173, 0.7],
      'Chevrolet' => [214_604, 0.5],
      'Alfa Romeo' => [119_095, 0.3],
      'Subaru' => [123_887, 0.3],
      'Daihatsu' => [78_619, 0.2],
      'Jaguar' => [73_932, 0.2],
      'Jeep' => [112_467, 0.2],
      'Land Rover' => [108_056, 0.2],
      'Chrysler' => [59_001, 0.1],
      'DS' => [33_607, 0.1],
      'Lancia' => [28_860, 0.1],
      'Lexus' => [27_282, 0.1],
      'MG Rover' => [28_777, 0.1],
      'Saab' => [44_345, 0.1],
    }
  end

  def self.colors
    @colors ||= %w[
      gold_yellow
      gray_silver
      pink_purple_violet
      black
      silver
      gray
      white
      beige
      blue
      brown
      yellow
      green
      red
      violet
      purple
      pink
      orange
      gold
    ]
  end

  def self.kinds
    @kinds ||= %w[
      PKW
      LKW
      Motorrad
    ]
  end

  def self.durations
    @durations ||= [
      ['bis zu 2 Minuten', 1],
      ['länger als 2 Minuten', 2],
      ['länger als 3 Minuten', 3],
      ['länger als 4 Minuten', 4],
      ['länger als 5 Minuten', 5],
      ['länger als 6 Minuten', 6],
      ['länger als 7 Minuten', 7],
      ['länger als 8 Minuten', 8],
      ['länger als 9 Minuten', 9],
      ['länger als 10 Minuten', 10],
      ['länger als 15 Minuten', 15],
      ['länger als 30 Minuten', 30],
      ['länger als 45 Minuten', 45],
      ['länger als 1 Stunde', 60],
      ['länger als 3 Stunden', 180],
    ]
  end
end
