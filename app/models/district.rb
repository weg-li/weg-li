class District < Struct.new(:name, :email, :zoom, :latitude, :longitude)
  HAMBURG = District.new('hamburg', 'anzeigenbussgeldstelle@eza.hamburg.de', 12, 53.56544, 9.95947)
  LUENEBURG = District.new('lueneburg', 'bussgeldstelle@landkreis.lueneburg.de')
  BREMEN = District.new('bremen', 'bussgeldstelle@ordnungsamt.bremen.de')

  ALL = [
    HAMBURG,
    LUENEBURG,
    BREMEN,
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
