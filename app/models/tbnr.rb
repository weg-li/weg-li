# frozen_string_literal: true

require "csv"

class Tbnr
  # die 1. Ziffer: Vorschrift, in der die OWi enthalten ist
  # die 2. und 3. Ziffer: Paragraf des Tat- bzw. Grundtatbestandes
  # die 4. ,5. und 6. Ziffer: Kenn-Nr. des Einzeltatbestandes (z. B. 999 = da Anzahl von 99 benennbaren Verstößen bereits überschritten ist)
  NUMBERS = {}

  RULES = {
    1 => "StVO",
    2 => "FeV",
    3 => "StVZO",
    4 => "StVG",
    5 => "Ferienreiseverordnung oder GGVSEB",
    6 => "Elektrokleinstfahrzeuge-Verordnung",
    7 => "Kenn-Nr. für die Tabellen",
    8 => "FZV",
    9 =>
      "Auffangtatbestand zur freien Verfügung, sofern kein auf den Sachverhalt zutreffender Tatbestand vorgesehen ist",
  }

  attr_reader :tbnr

  def initialize(tbnr)
    raise "tbnr #{tbnr} must be 6 digits" unless tbnr =~ /\A\d{6}\Z/

    @tbnr = tbnr
    @rule = tbnr[0].to_i
    @paragraph = tbnr[1..2].to_i
    @number = tbnr[3..6].to_i
  end

  def description
    "#{RULES[@rule]} / § #{@paragraph} / #{number_description(@number)}"
  end

  private

  def number_description(number)
    case number
    when 0..99
      "Tatbestände aus dem Verwarnungsgeldbereich, die nicht im Bußgeldkatalog enthalten sind"
    when 100..499
      "Tatbestände aus dem Verwarnungsgeldbereich, die im Bußgeldkatalog enthalten sind"
    when 500..599
      "Tatbestände aus dem Bußgeldbereich, die nicht im Bußgeldkatalog enthalten sind"
    when 600..999
      "Tatbestände aus dem Bußgeldbereich, die im Bußgeldkatalog enthalten sind"
    end
  end
end
