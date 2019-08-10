class District < Struct.new(:name, :email, :zoom, :latitude, :longitude)
  BERLIN = District.new('berlin', 'anzeige@bowi.berlin.de', 12, 52.520, 13.401)
  BREMEN = District.new('bremen', 'bussgeldstelle@ordnungsamt.bremen.de', 13, 53.078, 8.797)
  DORTMUND = District.new('dortmund', 'fremdanzeigen.verkehrsueberwachung@stadtdo.de', 13, 51.513, 7.460)
  FRANKFURT = District.new('frankfurt', 'owi.datenerfassung.amt32@stadt-frankfurt.de', 12, 50.109, 8.675)
  HAMBURG = District.new('hamburg', 'anzeigenbussgeldstelle@eza.hamburg.de', 12, 53.56544, 9.95947)
  KIEL = District.new('kiel', 'ad-bussgeldstelle@kiel.de', 13, 54.319, 10.118)
  LUENEBURG = District.new('lueneburg', 'bussgeldstelle@landkreis.lueneburg.de', 14, 53.249, 10.403)
  MUENSTER = District.new('muenster', 'kod@stadt-muenster.de', 14, 51.961, 7.622)

  ALL = [
    BERLIN,
    BREMEN,
    DORTMUND,
    FRANKFURT,
    HAMBURG,
    KIEL,
    LUENEBURG,
    MUENSTER,
  ]

  def self.names
    ALL.map(&:name)
  end

  def self.by_name(name)
    ALL.find { |district| district.name == name }
  end

  def map_data
    {
      zoom: zoom,
      latitude: latitude,
      longitude: longitude,
    }
  end

  def display_name
    I18n.t(name, scope: "users.districts")
  end

  def to_s
    name
  end
end
