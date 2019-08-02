class Notice < ActiveRecord::Base
  include Bitfields
  bitfield :flags, 1 => :empty, 2 => :parked

  include Incompletable

  before_validation :defaults

  reverse_geocoded_by :latitude, :longitude
  after_validation :geocode

  belongs_to :user
  has_many_attached :fotos

  validates :fotos, :registration, :charge, :address, :brand, :color, :date, presence: :true

  enum status: {open: 0, disabled: 1, analysing: 2, shared: 3}

  attr_accessor :recipients

  def self.from_param(token)
    find_by_token!(token)
  end

  def coordinates?
    latitude? && longitude?
  end

  def to_param
    token
  end

  private

  def defaults
    self.token ||= SecureRandom.hex(16)
  end
end
