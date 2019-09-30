class Notice < ActiveRecord::Base
  extend TimeSplitter::Accessors
  split_accessor :date

  include Bitfields
  bitfield :flags, 1 => :empty, 2 => :parked, 4 => :hinder, 8 => :parked_three_hours, 16 => :parked_one_hour

  include Incompletable

  attr_accessor :tweet_url

  before_validation :defaults

  geocoded_by :address, language: Proc.new { |model| I18n.locale }, no_annotations: true
  reverse_geocoded_by :latitude, :longitude, language: Proc.new { |model| I18n.locale }, no_annotations: true
  after_validation :geocode

  belongs_to :user
  belongs_to :district
  belongs_to :bulk_upload
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
      districts: District.count,
    }
  end

  def self.prepared_claim(token)
    Notice.joins(:user).where({ users: { access: :ghost} }).find_by(token: token)
  end

  def analyze!
    self.status = :analyzing
    save_incomplete!
    AnalyzerJob.set(wait: 3.seconds).perform_later(self)
  end

  def apply_favorites(registrations)
    other = Notice.shared.since(1.month.ago).find_by(registration: registrations)
    if other
      self.registration = other.registration
      self.charge = other.charge
      self.brand = other.brand if other.brand?
      self.color = other.color if other.color?
    end
  end

  def similar_count(since: 1.month.ago)
    return 0 if registration.blank?

    @similar_count ||= Notice.since(since).where(registration: registration).count
  end

  def date_doubles
    return false if registration.blank?

    user.notices.where('DATE(date) = DATE(?)', date).where(registration: registration).where.not(id: id)
  end

  def photo_doubles
    user.photos_attachments.joins(:blob).where('active_storage_attachments.record_id != ?', id).where('active_storage_blobs.filename' => photos.map { |photo| photo.filename.to_s })
  end

  def district
    if self[:district_id]
      super
    else
      legacy = DistrictLegacy.by_name(self[:district_legacy])
      District.from_zip(legacy.zip)
    end
  end

  def zip
    address[/(\d{5})/, 1]
  end

  def coordinates?
    latitude? && longitude?
  end

  def map_data
    {
      latitude: latitude,
      longitude: longitude,
      charge: charge,
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
