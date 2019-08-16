class Notice < ActiveRecord::Base
  extend TimeSplitter::Accessors
  split_accessor :date

  include Bitfields
  bitfield :flags, 1 => :empty, 2 => :parked, 4 => :hinder, 8 => :parked_long

  include Incompletable

  before_validation :defaults

  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude, language: Proc.new { |model| I18n.locale }
  after_validation :geocode

  belongs_to :user
  has_many_attached :photos

  validates :photos, :registration, :charge, :address, :date, presence: :true

  enum status: {open: 0, disabled: 1, analyzing: 2, shared: 3}

  scope :since, -> (date) { where('notices.created_at > ?', date) }
  scope :for_public, -> () { where.not(status: :disabled) }

  attr_accessor :recipients

  def self.from_param(token)
    find_by_token!(token)
  end

  def self.statistics(date = 100.years.ago)
    {
      photos: since(date).joins(photos_attachments: :blob).count,
      all: since(date).count,
      incomplete: since(date).incomplete.count,
      shared: since(date).shared.count,
      users: User.where(id: since(date).pluck(:user_id)).count,
    }
  end

  def coordinates?
    latitude? && longitude?
  end

  def map_data
    {
      latitude: latitude,
      longitude: longitude,
    }
  end

  def to_param
    token
  end

  private

  def defaults
    self.token ||= SecureRandom.hex(16)
  end
end
