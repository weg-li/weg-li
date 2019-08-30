class Notice < ActiveRecord::Base
  extend TimeSplitter::Accessors
  split_accessor :date

  include Bitfields
  bitfield :flags, 1 => :empty, 2 => :parked, 4 => :hinder, 8 => :parked_long

  include Incompletable

  before_validation :defaults

  geocoded_by :address, language: Proc.new { |model| I18n.locale }, no_annotations: true
  reverse_geocoded_by :latitude, :longitude, language: Proc.new { |model| I18n.locale }, no_annotations: true
  after_validation :geocode

  belongs_to :user
  has_many_attached :photos

  validates :photos, :registration, :charge, :address, :date, presence: :true

  enum status: {open: 0, disabled: 1, analyzing: 2, shared: 3}

  scope :since, -> (date) { where('notices.created_at > ?', date) }
  scope :destroyable, -> () { where.not(status: :shared) }
  scope :for_public, -> () { where.not(status: :disabled) }

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
      all_users: User.since(date).count,
      districts: District.all.size,
    }
  end

  def analyze!
    self.status = :analyzing
    save_incomplete!
    AnalyzerJob.set(wait: 3.seconds).perform_later(self)
  end

  def district=(district)
    self[:district] = district.to_s
  end

  def district
    District.by_name(self[:district])
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
