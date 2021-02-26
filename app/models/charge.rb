class Charge < ActiveRecord::Base
  validates :tbnr, :description, presence: true
  validates :tbnr, length: {is: 6}

  has_many :charge_variants, -> { joins(:charge).where('charge_variants.date = charges.valid_from') }, foreign_key: :table_id, primary_key: :variant_table_id

  scope :active, -> { where(valid_to: nil) }

  def self.from_param(tbnr)
    find_by!(tbnr: tbnr)
  end

  # classification
  # Schluessel,Bezeichnung,Laenge,Genauigkeit
  # '0','sonstige','',''
  # '1','Lichtzeichen','',''
  # '2','Behinderung','',''
  # '3','Gefährdung','',''
  # '4','Unfall','',''
  # '5','Halt- und Parkverstoß','',''
  # '6','Geschwindigkeitsüberschreitung','3','0'
  # '7','Überladung','',''
  # '8','Alkohol und Rauschmittel','',''
  # '9','Abstandsmessung','',''
  # 'M','Messangabe','',''

  FAP = {
    'A' => 'schwerwiegende Zuwiderhandlung bei Fahrerlaubnis auf Probe',
    'B' => 'weniger schwerwiegende Zuwiderhandlung bei Fahrerlaubnis auf Probe',
  }

  def fap_description
    FAP[fap] || '-'
  end

  def to_param
    tbnr
  end

  CHARGES = {
    112442 => 'Parken auf einem unbeschilderten Radweg',
    141292 => 'Parken auf einem Fußgängerüberweg',
    141100 => 'Parken auf einem Radweg (Zeichen 237)',
    141112 => 'Parken auf einem Geh- und Radweg (Zeichen 240/241)',
    141022 => 'Parken auf einer Fahrradstraße (Zeichen 244.1/244.2)',
    142272 => 'Parken verbotswidrig auf einem Schutzstreifen für den Radverkehr (Zeichen 340)',
    112402 => 'Parken verbotswidrig auf einem Gehweg',
    142103 => 'Parken in einem verkehrsberuhigten Bereich (Zeichen 325.1, 325.2) verbotswidrig außerhalb der zum Parken gekennzeichneten Flächen',
    141106 => 'Parken in einem Fußgängerbereich, der (durch Zeichen 239/242.1, 242.2/250) gesperrt war',
    141302 => 'Parken in einem Abstand von weniger als 5 Meter vor einem Fußgängerüberweg',
    -1 => 'Parken weniger als 8 Meter vor der Kreuzung/Einmündung, obwohl in Fahrtrichtung rechts neben der Fahrbahn ein Radweg baulich angelegt ist',
    112262 => 'Parken weniger als 5 Meter vor/hinter der Kreuzung/Einmündung',
    141312 => 'Parken im absolutem Haltverbot (Zeichen 283)',
    141322 => 'Parken unzulässig im eingeschränkten Haltverbot (Zeichen 286)',
    141245 => 'Parken unzulässig auf einer Sperrfläche (Zeichen 298)',
    112102 => 'Parken an einer engen/unübersichtlichen Straßenstelle',
    112112 => 'Parken im Bereich einer scharfen Kurve',
    112412 => 'Parken unzulässig in der zweiten Reihe',
    137012 => 'Parken näher als 10 Meter vor einem Lichtzeichen',
    112216 => 'Parken vor oder in einer amtlich gekennzeichneten Feuerwehrzufahrt',
    141382 => 'Parken verbotswidrig im Bereich eines Taxenstandes (Zeichen 229)',
    112282 => 'Parken verbotswidrig und verhinderten dadurch die Benutzung gekennzeichneter Parkflächen',
    112292 => 'Parken im Bereich einer Grundstückseinfahrt bzw. -ausfahrt',
    112302 => 'Parken auf einer schmalen Fahrbahn gegenüber einer Grundstückseinfahrt/Grundstücks-ausfahrt',
    112372 => 'Parken vor einer Bordsteinabsenkung',
    112042 => 'Parken verbotswidrig auf der linken Fahrbahnseite/dem linken Seitenstreifen',
    112062 => 'Parken nicht am rechten Fahrbahnrand',
    112428 => 'Parken im Fahrraum von Schienenfahrzeugen',
    141332 => 'Parken links von einer Fahrbahnbegrenzung (Zeichen 295)',
    141062 => 'Parken in einem Verkehrsbereich, der (durch Zeichen 250/251/253/255/260) gesperrt war',
    141342 => 'Parken auf einem durch Richtungspfeile (Zeichen 297) gekennzeichneten Fahrbahnteil',
    141352 => 'Parken innerhalb einer Grenzmarkierung (Zeichen 299) für ein Haltverbot',
    141362 => 'Parken näher als 10 Meter vor einem Andreaskreuz (Zeichen 201)/Zeichen 205 (Vorfahrt gewähren!)/Zeichen 206 (Halt! Vorfahrt gewähren!) und verdeckten dieses',
    141432 => 'Parken innerhalb eines Kreisverkehrs (Zeichen 215)',
    141402 => 'Parken in einem Abstand von weniger als 15 Metern von einem Haltestellenschild',
    141412 => 'Parken, obwohl zwischen Ihrem Fahrzeug und der Fahrstreifenbegrenzung (Zeichen 295/296) ein Abstand von weniger als 3 Metern verblieb',
    141422 => 'Parken innerhalb einer Grenzmarkierung (Zeichen 299) für ein Parkverbot',
    112432 => 'Parken bei zulässigem Gehwegparken (Zeichen 315) nicht auf dem Gehweg',
    141377 => 'Parken auf einem Sonderfahrstreifen für Omnibusse des Linienverkehrs (Zeichen 245)',
    142278 => 'Parken auf einem gekennzeichneten Behindertenparkplatz',
    -2 => 'Parken mit Verbrenner vor Elektroladesäule',
    -3 => 'Parken auf einer Grünfläche',
    -4 => 'Parken auf einer Baumscheibe',
    112076 => 'Parken in der Einbahnstraße entgegen der Fahrtrichtung',
    141042 => 'Parken auf einem Gehweg, der durch Parkflächenmarkierung zum Gehwegparken freigegeben war, bei mehr als 2,8 t zulässiger Gesamtmasse',
    142262 => 'Parken auf einem Parkplatz (Zeichen 314), obwohl dies durch Zusatzzeichen *) für Sie verboten war',
    0 => 'Sonstiges Parkvergehen (siehe Hinweise)',
  }

  def self.plain_charges
    @plain_charges ||= CHARGES.values
  end

  def self.plain_charges_tbnr(charge)
    @plain_charges_tbnr ||= CHARGES.invert
    @plain_charges_tbnr[charge]
  end
end
