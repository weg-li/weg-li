class District < Struct.new(:name, :email)
  HAMBURG = District.new('hamburg', 'anzeigenbussgeldstelle@eza.hamburg.de')
  LUENEBURG = District.new('lueneburg', 'TODO@lueneburg.de')
  BREMEN = District.new('bremen', 'TODO@bremen.de')

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

  def to_s
    name
  end
end
