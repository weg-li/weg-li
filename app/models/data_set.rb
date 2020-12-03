class DataSet < ApplicationRecord
  belongs_to :setable, polymorphic: true
  belongs_to :keyable, polymorphic: true

  enum kind: { google_vision: 0, exif: 1}
end
