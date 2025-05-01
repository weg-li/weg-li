# frozen_string_literal: true

require "csv"

class Vehicle
  def self.cars
    @cars ||= JSON.load(Rails.root.join("config/data/cars.json"))
  end

  def self.plates
    @plates ||= JSON.load(Rails.root.join("config/data/plates.json"))
  end

  def self.most_often?(matches)
    return false if matches.blank?

    matches.group_by(&:itself).max_by { |_match, group| group.size }[0]
  end

  def self.by_likelyhood(matches)
    return [] if matches.blank?

    groups = matches.group_by { |key, _| key.gsub(/\W/, "") }
    groups = groups.sort_by { |_, group| group.sum { |_, probability| probability }.fdiv(matches.size) }
    groups.map { |match| match[1].flatten[0] }.reverse
  end

  def self.most_likely?(matches)
    by_likelyhood(matches).first
  end

  def self.plate?(text, prefixes: nil, text_divider: ' ')
    text = normalize(text)

    if prefixes.present? && text =~ plate_regex(prefixes)
      ["#{$1}#{text_divider}#{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 1.2]
    elsif prefixes.present? && text =~ relaxed_plate_regex(prefixes)
      ["#{$1}#{text_divider}#{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 1.1]
    elsif text =~ plate_regex
      ["#{$1}#{text_divider}#{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 1.0]
    elsif text =~ relaxed_plate_regex
      ["#{$1}#{text_divider}#{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 0.8]
    elsif text =~ quirky_mode_plate_regex
      ["#{$1}#{text_divider}#{$2} #{$3}#{$4.to_s.gsub(/[^E]+/, '')}", 0.5]
    end
  end

  def self.normalize(text, text_divider: ' ')
    return "" if text.blank?

    text
      .gsub("ö", "Ö")
      .gsub("ä", "Ä")
      .gsub("ü", "Ü")
      .gsub(/^([^A-Z,ÖÄÜ])+/, "")
      .gsub(/([^E,0-9])+$/, "")
      .gsub(/([^A-Z,ÖÄÜ0-9])+/, " ")
      .gsub(/([A-Z,ÖÄÜ]+) ([A-Z,ÖÄÜ]+)\s?(\d+)(\s?E)?/, "\\1#{text_divider}\\2 \\3\\4")
  end

  def self.plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^(#{prefixes.join('|')}) ([A-Z]{1,3})\s?(\\d{1,4})(\s?E)?$")
  end

  def self.relaxed_plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^(#{prefixes.join('|')})O?:? ?([A-Z]{1,3})\s?(\\d{1,4})(\s?E)?$")
  end

  def self.quirky_mode_plate_regex(prefixes = Vehicle.plates.keys)
    Regexp.new("^P?D?C?O?B?(#{prefixes.join('|')})O?:? ?0?([A-Z]{1,3})\s?(\\d{1,4})(\s?E)?$")
  end

  def self.district_for_plate_prefix(text)
    prefixes = normalize(text)[plate_regex, 1]
    plates[prefixes]
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
end
