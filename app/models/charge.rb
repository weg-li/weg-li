# frozen_string_literal: true

class Charge < ApplicationRecord
  validates :tbnr, :description, presence: true
  validates :tbnr, length: { is: 6 }

  has_many :charge_variants,
           -> {
             joins(:charge).where("charge_variants.date = charges.valid_from")
           },
           foreign_key: :table_id,
           primary_key: :variant_table_id

  scope :active, -> { where(valid_to: nil).where("fine > 0") }
  scope :ordered, -> { order(valid_from: :desc) }

  acts_as_api

  api_accessible :public_beta do |template|
    %i[
      tbnr
      description
      fine
      bkat
      penalty
      fap
      points
      valid_from
      valid_to
      implementation
      classification
      variant_table_id
      rule_id
      table_id
      required_refinements
      number_required_refinements
      max_fine
      created_at
      updated_at
    ].each { |key| template.add(key) }
  end

  CLASSIFICATIONS = {
    0 => "sonstige",
    1 => "Lichtzeichen",
    2 => "Behinderung",
    3 => "Gefährdung",
    4 => "Unfall",
    5 => "Halt- und Parkverstoß",
    6 => "Geschwindigkeitsüberschreitung",
    7 => "Überladung",
    8 => "Alkohol und Rauschmittel",
    9 => "Abstandsmessung",
  }

  FAP = {
    "A" => "schwerwiegende Zuwiderhandlung bei Fahrerlaubnis auf Probe",
    "B" => "weniger schwerwiegende Zuwiderhandlung bei Fahrerlaubnis auf Probe",
  }

  UPDATED_CHARGES = [
    [
      "1",
      "Parken auf einem unbeschilderten Radweg",
      "112474",
      "112675",
      "",
      "neu",
    ],
    ["2", "Parken auf einem Fußgängerüberweg", "141292", "141293", "", "neu"],
    [
      "3",
      "Parken auf einem Radweg (Zeichen 237)",
      "141174",
      "141775",
      "",
      "neu",
    ],
    [
      "4",
      "Parken auf einem Geh- und Radweg (Zeichen 240/241)",
      "141194",
      "141795",
      "",
      "neu",
    ],
    [
      "5",
      "Parken auf einer Fahrradstraße (Zeichen 244.1/244.2)",
      "141124",
      "141525",
      "",
      "neu",
    ],
    [
      "6",
      "Halten auf einem Schutzstreifen (Zeichen 340)",
      "142170",
      "142671",
      "",
      "neu",
    ],
    [
      "7",
      "Parken verbotswidrig auf einem Gehweg",
      "112454",
      "112655",
      "",
      "neu",
    ],
    [
      "8",
      "Parken in einem verkehrsberuhigten Bereich (Zeichen 325.1, 325.2) verbotswidrig außerhalb der zum Parken gekennzeichneten Flächen",
      "142103",
      "142104",
      "",
      "",
    ],
    [
      "9",
      "Parken in einer Fußgängerzone Zeichen 239/240/241/242.1/250",
      "141184",
      "141785",
      "",
      "neu",
    ],
    [
      "10",
      "Parken in einem Abstand von weniger als 5 Meter vor einem Fußgängerüberweg",
      "141302",
      "141303",
      "",
      "",
    ],
    [
      "11",
      "Parken weniger als 8 Meter vor der Kreuzung/Einmündung, obwohl in Fahrtrichtung rechts neben der Fahrbahn ein Radweg baulich angelegt ist",
      "112266",
      "112267",
      "",
      "neu",
    ],
    [
      "12",
      "Parken weniger als 5 Meter vor/hinter der Kreuzung/Einmündung",
      "112262",
      "112263",
      "",
      "",
    ],
    [
      "13",
      "Parken im absolutem Haltverbot (Zeichen 283)",
      "141312",
      "141313",
      "",
      "",
    ],
    [
      "14",
      "Parken unzulässig im eingeschränkten Haltverbot (Zeichen 286)",
      "141322",
      "141323",
      "",
      "",
    ],
    [
      "15",
      "Parken unzulässig auf einer Sperrfläche (Zeichen 298)",
      "141245",
      "",
      "",
      "",
    ],
    [
      "16",
      "Parken an einer engen/unübersichtlichen Straßenstelle",
      "112102",
      "112103",
      "",
      "",
    ],
    [
      "17",
      "Parken im Bereich einer scharfen Kurve",
      "112112",
      "112113",
      "",
      "",
    ],
    [
      "18",
      "Parken unzulässig in der zweiten Reihe",
      "112464",
      "112665",
      "",
      "neu",
    ],
    [
      "19",
      "Parken näher als 10 Meter vor einem Lichtzeichen",
      "137012",
      "137013",
      "",
      "",
    ],
    [
      "20",
      "Parken vor oder in einer amtlich gekennzeichneten Feuerwehrzufahrt",
      "112216",
      "",
      "",
      "",
    ],
    [
      "21",
      "Parken verbotswidrig im Bereich eines Taxenstandes (Zeichen 229)",
      "141382",
      "141383",
      "",
      "",
    ],
    [
      "22",
      "Parken verbotswidrig und verhinderten dadurch die Benutzung gekennzeichneter Parkflächen",
      "112282",
      "112283",
      "",
      "",
    ],
    [
      "23",
      "Parken im Bereich einer Grundstückseinfahrt bzw. -ausfahrt",
      "112292",
      "112293",
      "",
      "",
    ],
    [
      "24",
      "Parken auf einer schmalen Fahrbahn gegenüber einer Grundstückseinfahrt/Grundstücksausfahrt",
      "112302",
      "112303",
      "",
      "",
    ],
    ["25", "Parken vor einer Bordsteinabsenkung", "112372", "112373", "", ""],
    [
      "26",
      "Parken verbotswidrig auf der linken Fahrbahnseite/dem linken Seitenstreifen",
      "112042",
      "112043",
      "",
      "",
    ],
    ["27", "Parken nicht am rechten Fahrbahnrand", "112062", "112063", "", ""],
    [
      "28",
      "Parken im Fahrraum von Schienenfahrzeugen",
      "112428",
      "112429",
      "",
      "",
    ],
    [
      "29",
      "Parken links von einer Fahrbahnbegrenzung (Zeichen 295)",
      "141332",
      "141333",
      "",
      "",
    ],
    [
      "30",
      "Parken in einem Verkehrsbereich, der (durch Zeichen 250/251/253/255/260) gesperrt war",
      "141164",
      "",
      "neu",
      "",
    ],
    [
      "31",
      "Parken auf einem durch Richtungspfeile (Zeichen 297) gekennzeichneten Fahrbahnteil",
      "141342",
      "141343",
      "",
      "",
    ],
    [
      "32",
      "Parken innerhalb einer Grenzmarkierung (Zeichen 299) für ein Haltverbot",
      "141352",
      "141353",
      "",
      "",
    ],
    [
      "33",
      "Parken näher als 10 Meter vor einem Andreaskreuz (Zeichen 201)/Zeichen 205 (Vorfahrt gewähren!)/Zeichen 206 (Halt! Vorfahrt gewähren!) und verdeckten dieses",
      "141360",
      "141361",
      "",
      "neu",
    ],
    [
      "34",
      "Parken innerhalb eines Kreisverkehrs (Zeichen 215)",
      "141432",
      "141433",
      "",
      "",
    ],
    [
      "35",
      "Parken in einem Abstand von weniger als 15 Metern von einem Haltestellenschild",
      "141402",
      "141403",
      "",
      "",
    ],
    [
      "36",
      "Parken, obwohl zwischen Ihrem Fahrzeug und der Fahrstreifenbegrenzung (Zeichen 295/296) ein Abstand von weniger als 3 Metern verblieb",
      "141412",
      "141413",
      "",
      "",
    ],
    [
      "37",
      "Parken innerhalb einer Grenzmarkierung (Zeichen 299) für ein Parkverbot",
      "141026",
      "141027",
      "",
      "neu",
    ],
    [
      "38",
      "Parken bei zulässigem Gehwegparken (Zeichen 315) nicht auf dem Gehweg",
      "112484",
      "112685",
      "",
      "neu",
    ],
    [
      "39",
      "Parken auf einem Sonderfahrstreifen für Omnibusse des Linienverkehrs (Zeichen 245)",
      "141377",
      "",
      "",
      "neu nur Benutzen des Fahrstreifens 141202 Beh.141203",
    ],
    [
      "40",
      "Parken auf einem gekennzeichneten Behindertenparkplatz",
      "142278",
      "",
      "",
      "",
    ],
    [
      "41",
      "Parken mit Verbrenner vor Elektroladesäule",
      "142262",
      "142263",
      "E-Fahrzeuge während des Ladevorgangs",
      "",
    ],
    ["42", "Parken auf einer Grünfläche", "901400", "", "", ""],
    # ['43', 'Parken auf einer Baumscheibe', '-4', '', '', 'unbekannt'],
    ["44", "Sonstiges Parkvergehen (siehe Hinweise)", "0", "", "", ""],
  ]

  CHARGES = UPDATED_CHARGES.to_h { |a| [a[2].to_i, a[1]] }

  class << self
    def plain_charges
      @plain_charges ||= CHARGES.values
    end

    def plain_charges_tbnr(charge)
      @plain_charges_tbnr ||= CHARGES.invert
      @plain_charges_tbnr[charge]
    end

    def classification_name(classification)
      CLASSIFICATIONS[classification.to_i] || "-"
    end

    def from_param(param)
      by_param(param).ordered.first!
    end

    def by_param(param)
      where(tbnr: parse_param(param))
    end

    def parse_param(param)
      param.split("-").first || param
    end
  end

  def classification_name
    self.class.classification_name(classification)
  end

  def fap_description
    FAP[fap] || "-"
  end

  def to_param
    "#{tbnr}-#{description.parameterize}"
  end
end
