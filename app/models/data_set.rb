class DataSet < ApplicationRecord
  belongs_to :setable, polymorphic: true
  belongs_to :keyable, polymorphic: true

  enum kind: { google_vision: 0, exif: 1}

  # TODO: use these in the analyzer
  def registrations
    raise "not supported by #{kind}" unless google_vision?

    Annotator.grep_text(data.deep_symbolize_keys) { |it| Vehicle.plate?(it) }
  end

  def brands
    raise "not supported by #{kind}" unless google_vision?

    Annotator.grep_text(data.deep_symbolize_keys) { |it| Vehicle.brand?(it) }
  end

  def colors
    raise "not supported by #{kind}" unless google_vision?

    Annotator.dominant_colors(data.deep_symbolize_keys)
  end
end
