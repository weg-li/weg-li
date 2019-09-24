class DistrictLegacy < Struct.new(:display_name, :name, :email, :zoom, :latitude, :longitude)
  AICHTAL = DistrictLegacy.new('Aichtal', 'aichtal', 'stadt@aichtal.de', 15, 48.628, 9.257)
  BAMBERG = DistrictLegacy.new('Bamberg', 'bamberg', 'zbs-pued@stadt.bamberg.de', 15, 49.894, 10.890)
  BERLIN = DistrictLegacy.new('Berlin', 'berlin', 'anzeige@bowi.berlin.de', 12, 52.520, 13.401)
  BIELEFELD = DistrictLegacy.new('Bielefeld', 'bielefeld', 'bussgeld.verkehr@bielefeld.de', 14, 52.020, 8.529)
  BOCHUM = DistrictLegacy.new('Bochum', 'bochum', 'amt30@bochum.de', 14, 51.481, 7.213)
  BONN = DistrictLegacy.new('Bonn', 'bonn', 'stvo@bonn.de', 14, 50.735, 7.098)
  BRAUNSCHWEIG = DistrictLegacy.new('Braunschweig', 'braunschweig', 'gewerbe.ordnung@braunschweig.de', 15, 52.264, 10.520)
  BREMEN = DistrictLegacy.new('Bremen', 'bremen', 'bussgeldstelle@ordnungsamt.bremen.de', 13, 53.078, 8.797)
  BUXTEHUDE = DistrictLegacy.new('Buxtehude', 'buxtehude', 'fg32@stadt.buxtehude.de', 15, 53.465, 9.687)
  DARMSTADT = DistrictLegacy.new('Darmstadt', 'darmstadt', 'buergerordnungsamt@darmstadt.de', 15, 49.871, 8.652)
  DORTMUND = DistrictLegacy.new('Dortmund', 'dortmund', 'fremdanzeigen.verkehrsueberwachung@stadtdo.de', 13, 51.513, 7.460)
  DUESSELDORF = DistrictLegacy.new('Düsseldorf', 'duesseldorf', 'bussgeldstelle@duesseldorf.de', 13, 51.219, 6.778)
  ERFURT = DistrictLegacy.new('Erfurt', 'erfurt', 'buergeramt@erfurt.de', 15, 50.977, 11.027)
  FILDERSTADT = DistrictLegacy.new('Filderstadt', 'filderstadt', 'amt32@filderstadt.de', 15, 48.676, 9.217)
  FRANKFURT = DistrictLegacy.new('Frankfurt', 'frankfurt', 'owi.datenerfassung.amt32@stadt-frankfurt.de', 12, 50.109, 8.675)
  HAMBURG = DistrictLegacy.new('Hamburg', 'hamburg', 'anzeigenbussgeldstelle@eza.hamburg.de', 12, 53.56544, 9.95947)
  HANNOVER = DistrictLegacy.new('Hannover', 'hannover', '32.41@hannover-stadt.de', 13, 52.374, 9.734)
  HANNOVER_REGION = DistrictLegacy.new('Großraum Hannover', 'hannover_region', 'verkehrsowi@region-hannover.de', 11, 52.374, 9.734)
  HEIDELBERG = DistrictLegacy.new('Heidelberg', 'heidelberg', 'ordnungswidrigkeiten@heidelberg.de', 15, 49.408, 8.691)
  HESSEN_REGION = DistrictLegacy.new('Großraum Hessen', 'hessen_region', 'post@zbs.hessen.de', 10, 50.430, 8.849)
  HILCHENBACH = DistrictLegacy.new('Hilchenbach', 'hilchenbach', 'c.wandtke@hilchenbach.de', 14, 50.996, 8.110)
  HILDEN = DistrictLegacy.new('Hilden', 'hilden', 'ordnungsamt@hilden.de', 15, 51.169, 6.932)
  HERNE = DistrictLegacy.new('Herne', 'herne', 'ordnungsamt@herne.de', 13, 51.537, 7.195)
  KARLSRUHE = DistrictLegacy.new('Karlsruhe', 'karlsruhe', 'kod@oa.karlsruhe.de', 14, 49.007, 8.396)
  KIEL = DistrictLegacy.new('Kiel', 'kiel', 'ad-bussgeldstelle@kiel.de', 13, 54.319, 10.118)
  KOELN = DistrictLegacy.new('Köln', 'koeln', 'owi-anzeigen@koeln.de', 13, 50.937, 6.957)
  KREUZTAL = DistrictLegacy.new('Kreuztal', 'kreuztal', 'ordnungsamt@kreuztal.de', 15, 50.968, 7.988)
  LEIPZIG = DistrictLegacy.new('Leipzig', 'leipzig', 'ordnungsamt@leipzig.de', 13, 51.340, 12.374)
  LUENEBURG = DistrictLegacy.new('Lüneburg', 'lueneburg', 'bussgeldstelle@landkreis.lueneburg.de', 14, 53.249, 10.403)
  MAINZ = DistrictLegacy.new('Mainz', 'mainz', 'verkehrsueberwachungsamt@stadt.mainz.de', 14, 49.999, 8.268)
  MANNHEIM = DistrictLegacy.new('Mannheim', 'mannheim', 'bereich31@mannheim.de', 15, 49.487, 8.462)
  MOENCHENGLADBACH = DistrictLegacy.new('Mönchengladbach', 'moenchengladbach', 'bussgeldstelle@moenchengladbach.de', 15, 51.196, 6.439)
  MUENCHEN = DistrictLegacy.new('München', 'muenchen', 'verkehrsueberwachung.kvr@muenchen.de', 13, 48.133, 11.565)
  MUENSTER = DistrictLegacy.new('Münster', 'muenster', 'kod@stadt-muenster.de', 14, 51.961, 7.622)
  NEUSS = DistrictLegacy.new('Neuss', 'neuss', 'verkehrslenkung@stadt.neuss.de', 15, 51.198, 6.690)
  NUERNBERG = DistrictLegacy.new('Nürnberg', 'nuernberg', 'info@zv-kvue.nuernberg.de', 15, 49.450, 11.076)
  NUERTINGEN = DistrictLegacy.new('Nürtingen', 'nuertingen', 'ordnungsamt.stadt@nuertingen.de', 15, 48.625, 9.344)
  RAVENSBURG = DistrictLegacy.new('Ravensburg', 'ravensburg', 'ordnungsamt@ravensburg.de', 15, 47.781, 9.612)
  SAARBRUECKEN = DistrictLegacy.new('Saarbrücken', 'saarbruecken', 'ordnungsamt@saarbruecken.de', 15, 49.233, 6.995)
  SIEGEN = DistrictLegacy.new('Siegen', 'siegen', 'bussgeldstelle@siegen.de', 14, 50.875, 8.018)
  STUTTGART = DistrictLegacy.new('Stuttgart', 'stuttgart', 'verkehrsueberwachung@stuttgart.de', 14, 48.774, 9.176)
  TUEBINGEN = DistrictLegacy.new('Tübingen', 'tuebingen', 'verkehrsabteilung@tuebingen.de', 15, 48.520, 9.053)
  ZWEIBRUECKEN = DistrictLegacy.new('Zweibrücken', 'zweibruecken', 'ordnungsamt@zweibruecken.de', 16, 49.249, 7.360)
  # https://hamburg.adfc.de/verkehr/maengelmelder/falschparker/
  # https://www.leipzig.de/buergerservice-und-verwaltung/sicherheit-und-ordnung/kommunale-verkehrsueberwachung/ueberwachung-des-ruhenden-verkehrs-politessen/

  ALL = [
    AICHTAL,
    BAMBERG,
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
    ERFURT,
    FILDERSTADT,
    FRANKFURT,
    HAMBURG,
    HANNOVER,
    HANNOVER_REGION,
    HEIDELBERG,
    HESSEN_REGION,
    HILCHENBACH,
    HILDEN,
    HERNE,
    KARLSRUHE,
    KIEL,
    KOELN,
    KREUZTAL,
    LEIPZIG,
    LUENEBURG,
    MAINZ,
    MANNHEIM,
    MOENCHENGLADBACH,
    MUENCHEN,
    MUENSTER,
    NEUSS,
    NUERNBERG,
    NUERTINGEN,
    RAVENSBURG,
    SAARBRUECKEN,
    SIEGEN,
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

  def to_s
    name
  end
end
