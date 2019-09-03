class District < Struct.new(:name, :email, :zoom, :latitude, :longitude)
  AICHTAL = District.new('aichtal', 'stadt@aichtal.de', 15, 48.628, 9.257)
  BERLIN = District.new('berlin', 'anzeige@bowi.berlin.de', 12, 52.520, 13.401)
  BIELEFELD = District.new('bielefeld', 'bussgeld.verkehr@bielefeld.de', 14, 52.020, 8.529)
  BOCHUM = District.new('bochum', 'amt30@bochum.de', 14, 51.481, 7.213)
  BONN = District.new('bonn', 'stvo@bonn.de', 14, 50.735, 7.098)
  BRAUNSCHWEIG = District.new('braunschweig', 'gewerbe.ordnung@braunschweig.de', 15, 52.264, 10.520)
  BREMEN = District.new('bremen', 'bussgeldstelle@ordnungsamt.bremen.de', 13, 53.078, 8.797)
  BUXTEHUDE = District.new('buxtehude', 'fg32@stadt.buxtehude.de', 15, 53.465, 9.687)
  DARMSTADT = District.new('darmstadt', 'buergerordnungsamt@darmstadt.de', 15, 49.871, 8.652)
  DORTMUND = District.new('dortmund', 'fremdanzeigen.verkehrsueberwachung@stadtdo.de', 13, 51.513, 7.460)
  DUESSELDORF = District.new('duesseldorf', 'bussgeldstelle@duesseldorf.de', 13, 51.219, 6.778)
  FILDERSTADT = District.new('filderstadt', 'amt32@filderstadt.de', 15, 48.676, 9.217)
  FRANKFURT = District.new('frankfurt', 'owi.datenerfassung.amt32@stadt-frankfurt.de', 12, 50.109, 8.675)
  # https://hamburg.adfc.de/verkehr/maengelmelder/falschparker/
  HAMBURG = District.new('hamburg', 'anzeigenbussgeldstelle@eza.hamburg.de', 12, 53.56544, 9.95947)
  HANNOVER = District.new('hannover', '32.41@hannover-stadt.de', 13, 52.374, 9.734)
  HANNOVER_REGION = District.new('hannover_region', 'verkehrsowi@region-hannover.de', 11, 52.374, 9.734)
  HESSEN_REGION = District.new('hessen_region', 'post@zbs.hessen.de', 10, 50.430, 8.849)
  HILDEN = District.new('hilden', 'ordnungsamt@hilden.de', 15, 51.169, 6.932)
  HERNE = District.new('herne', 'ordnungsamt@herne.de', 13, 51.537, 7.195)
  KIEL = District.new('kiel', 'ad-bussgeldstelle@kiel.de', 13, 54.319, 10.118)
  KOELN = District.new('koeln', 'owi-anzeigen@koeln.de', 13, 50.937, 6.957)
  # https://www.leipzig.de/buergerservice-und-verwaltung/sicherheit-und-ordnung/kommunale-verkehrsueberwachung/ueberwachung-des-ruhenden-verkehrs-politessen/
  LEIPZIG = District.new('leipzig', 'ordnungsamt@leipzig.de', 13, 51.340, 12.374)
  LUENEBURG = District.new('lueneburg', 'bussgeldstelle@landkreis.lueneburg.de', 14, 53.249, 10.403)
  MUENCHEN = District.new('muenchen', 'verkehrsueberwachung.kvr@muenchen.de', 13, 48.133, 11.565)
  MUENSTER = District.new('muenster', 'kod@stadt-muenster.de', 14, 51.961, 7.622)
  NEUSS = District.new('neuss', 'verkehrslenkung@stadt.neuss.de', 15, 51.198, 6.690)
  NUERNBERG = District.new('nuernberg', 'info@zv-kvue.nuernberg.de', 15, 49.450, 11.076)
  NUERTINGEN = District.new('nuertingen', 'ordnungsamt.stadt@nuertingen.de', 15, 48.625, 9.344)
  STUTTGART = District.new('stuttgart', 'verkehrsueberwachung@stuttgart.de', 14, 48.774, 9.176)
  TUEBINGEN = District.new('tuebingen', 'verkehrsabteilung@tuebingen.de', 15, 48.520, 9.053)
  ZWEIBRUECKEN = District.new('zweibruecken', 'ordnungsamt@zweibruecken.de', 16, 49.249, 7.360)

  ALL = [
    AICHTAL,
    BERLIN,
    BIELEFELD,
    BOCHUM,
    BONN,
    BRAUNSCHWEIG,
    BREMEN,
    BUXTEHUDE,
    DARMSTADT,
    DORTMUND,
    DUESSELDORF,
    FILDERSTADT,
    FRANKFURT,
    HAMBURG,
    HANNOVER,
    HANNOVER_REGION,
    HESSEN_REGION,
    HILDEN,
    HERNE,
    KIEL,
    KOELN,
    LEIPZIG,
    LUENEBURG,
    MUENCHEN,
    MUENSTER,
    NEUSS,
    NUERNBERG,
    NUERTINGEN,
    STUTTGART,
    TUEBINGEN,
    ZWEIBRUECKEN,
  ]

  def self.all
    ALL
  end

  def self.names
    all.map(&:name)
  end

  def self.by_name(name)
    all.find { |district| district.name == name }
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
