# frozen_string_literal: true

class Geo
  MAX_DISTANCE = 30

  POLICE_INSPECTIONS = {
    pi11: [48.136829, 11.580227], # Altstadt
    pi12: [48.146846, 11.574034], # Maxvorstadt
    pi13: [48.16939, 11.587729], # Schwabing
    pi14: [48.131928, 11.554514], # Westend
    pi15: [48.117885, 11.517866], # Sendling
    pi16: [48.14112, 11.56002], # Westend
    pi21: [48.1239, 11.584347], # Au
    pi22: [48.138747, 11.607372], # Bogenhausen
    pi23: [48.104362, 11.58274], # Giesing
    pi24: [48.104159, 11.642686], # Perlach
    pi25: [48.134147, 11.686738], # Trudering-Riem
    pi26: [48.228694, 11.670973], # Ismaning
    pi27: [48.106508, 11.741385], # Haar
    pi28: [48.056368, 11.674944], # Ottobrunn
    pi29: [48.092391, 11.503792], # Forstenried
    pi31: [48.060729, 11.621523], # Unterhaching
    pi32: [48.032487, 11.520145], # Grünwald
    pi41: [48.143038, 11.498862], # Laim
    pi42: [48.149388, 11.537184], # Neuhausen
    pi43: [48.185724, 11.553397], # Olympiapark
    pi44: [48.183075, 11.505478], # Moosach
    pi45: [48.146, 11.458703], # Pasing
    pi46: [48.10442, 11.42384], # Planegg
    pi47: [48.192195, 11.570237], # Milbertshofen
    pi48: [48.252436, 11.561391] # Oberschleißheim
  }

  def self.radians(degrees)
    degrees * Math::PI / 180
  end

  def self.distance(point_a, point_b)
    2 * 3961 *
      Math.asin(
        Math.sqrt(
          (Math.sin(radians((point_a.latitude - point_b.latitude) / 2))**2) +
            (
              Math.cos(radians(point_b.latitude)) *
                Math.cos(radians(point_a.latitude)) *
                (
                  Math.sin(
                    radians((point_a.longitude - point_b.longitude) / 2)
                  )**2
                )
            )
        )
      )
  end

  def self.regions
    @regions ||=
      begin
        result =
          JSON.parse(Rails.root.join("config/data/munich_regions.json").read)
        regions =
          result["features"].map do |data|
            Geo.new(
              data
                .dig("geometry", "coordinates")
                .first
                .map { |(lng, lat, _)| [lat, lng] }
            )
          end

        POLICE_INSPECTIONS.map do |name, point|
          region = regions.find { |it| it.contains?(point) }
          raise "did not find PI for #{name} and point #{point}!" unless region

          [name, region]
        end
      end
  end

  def self.suggest_email(point)
    region = regions.find { |_name, it| it.contains?(point) }

    "pp-mue.muenchen.#{region.first}@polizei.bayern.de" if region
  end

  def initialize(points)
    @points = points

    # A Polygon must be 'closed', the last point equal to the first point. Append the first point to the array to close the polygon
    @points << points[0] if points[0] != points[-1]
  end

  def contains?(point)
    # https://gist.github.com/kidbrax/1236253
    latitude = point[0]
    longitude = point[1]

    contains_point = false
    i = -1
    j = @points.size - 1
    while (i += 1) < @points.size
      a_point_on_polygon = @points[i]
      trailing_point_on_polygon = @points[j]
      if point_is_between_the_ys_of_the_line_segment?(
           a_point_on_polygon,
           trailing_point_on_polygon,
           latitude
         ) &&
           ray_crosses_through_line_segment?(
             a_point_on_polygon,
             trailing_point_on_polygon,
             latitude,
             longitude
           )
        contains_point = !contains_point
      end
      j = i
    end

    contains_point
  end

  private

  def point_is_between_the_ys_of_the_line_segment?(
    a_point_on_polygon,
    trailing_point_on_polygon,
    latitude
  )
    (
      a_point_on_polygon[0] <= latitude &&
        latitude < trailing_point_on_polygon[0]
    ) ||
      (
        trailing_point_on_polygon[0] <= latitude &&
          latitude < a_point_on_polygon[0]
      )
  end

  def ray_crosses_through_line_segment?(
    a_point_on_polygon,
    trailing_point_on_polygon,
    latitude,
    longitude
  )
    (
      longitude <
        (
          (trailing_point_on_polygon[1] - a_point_on_polygon[1]) *
            (latitude - a_point_on_polygon[0]) /
            (trailing_point_on_polygon[0] - a_point_on_polygon[0])
        ) + a_point_on_polygon[1]
    )
  end
end
