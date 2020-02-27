class Notice < ActiveRecord::Base
  include Statisticable

  ADDRESS_ZIP_PATTERN =/.+(\d{5}).+/

  extend TimeSplitter::Accessors
  split_accessor :date

  include Bitfields
  bitfield :flags, 1 => :vehicle_empty, 2 => :hazard_lights, 4 => :expired_checks

  include Incompletable

  acts_as_api

  api_accessible(:public_beta) do |template|
    %i(token status street city zip latitude longitude registration charge date photos).each { |key| template.add(key) }
    Notice.bitfields[:flags].keys.each { |key| template.add(key) }
  end

  before_validation :defaults

  geocoded_by :geocode_address, language: Proc.new { |model| I18n.locale }, no_annotations: true
  after_validation :geocode, if: :do_geocoding?

  belongs_to :user
  belongs_to :district, optional: true, foreign_key: :zip, primary_key: :zip
  belongs_to :bulk_upload, optional: true
  has_many_attached :photos
  has_many :replies, -> { order('created_at DESC') }, dependent: :destroy

  validates :photos, :registration, :charge, :street, :zip, :city, :date, :duration, :severity, presence: :true
  validates :zip, format: { with: /\d{5}/, message: 'PLZ ist nicht korrekt' }
  validates :token, uniqueness: true

  enum status: {open: 0, disabled: 1, analyzing: 2, shared: 3}
  enum severity: {standard: 0, hinder: 1, endanger: 2}

  scope :since, -> (date) { where('notices.created_at > ?', date) }
  scope :destroyable, -> () { where.not(status: :shared) }
  scope :for_public, -> () { where.not(status: :disabled) }
  scope :search, -> (term) { where('registration ILIKE :term', term: "%#{term}%") }
  scope :preselect, -> () { shared.limit(3) }

  def self.for_reminder
    open.joins(:user).where(date: [(21.days.ago.beginning_of_day)..(14.days.ago.end_of_day)]).merge(User.not_disable_reminders).merge(User.active)
  end

  def self.from_param(token)
    find_by!(token: token)
  end

  def self.from_email_address(email)
    token = email[/^([^-]+)@.+/, 1]
    find_by!(token: token)
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

  def wegli_email
    "#{token}@anzeige.weg-li.de"
  end

  def duplicate!
    notice = dup
    notice.token = nil
    notice.status = :open
    notice.photos.attach(photos.map(&:blob))
    notice.save_incomplete!
    notice.reload
  end

  def analyze!
    self.status = :analyzing
    save_incomplete!
    AnalyzerJob.perform_later(self)
  end

  def apply_dates(dates)
    sorted_dates = dates.compact.sort
    self.date = sorted_dates.first
    if date?
      duration = (sorted_dates.last.to_i - date.to_i)
      self.duration = durations.find { |d| duration >= d.minutes } || 1
    end
  end

  def durations
    Vehicle.durations.to_h.values.reverse
  end

  def apply_favorites(registrations)
    other = Notice.shared.since(1.month.ago).order(created_at: :desc).find_by(registration: registrations)
    if other
      self.registration = other.registration
      self.charge = other.charge if other.charge?
      self.brand = other.brand if other.brand?
      self.color = other.color if other.color?
      self.flags = other.flags if other.flags?
    end
  end

  def possible_registrations
    registrations = [registration]
    registrations += data.flat_map {|_, result| Annotator.grep_text(result.deep_symbolize_keys) { |string| Vehicle.plate?(string) } }.map(&:first)
    registrations.flatten.compact.uniq
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

  def meta
    photos.map(&:metadata).to_json
  end

  def coordinates?
    latitude? && longitude?
  end

  def do_geocoding?
    !coordinates? && zip? && city? && street?
  end

  def handle_geocoding
    if coordinates?
      results = Geocoder.search([latitude, longitude])
      if results.present?
        best_result = results.first
        self.zip = best_result.postal_code
        self.city = best_result.city
        self.street = "#{best_result.street} #{best_result.house_number}".strip
      end
    end
  end

  def file_name(extension = :pdf)
    "#{date.strftime('%Y-%m-%d %H-%M')} #{registration.gsub(' ', '-')}.#{extension}"
  end

  def full_address
    "#{street}, #{zip} #{city}"
  end

  def geocode_address
    # https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md
    "#{street.split(',').first}, #{zip}, #{city}, Deutschland"
  end

  def map_data(kind = :public, current_user: nil)
    basic = {
      latitude: latitude,
      longitude: longitude,
      charge: charge,
      date: date,
      zip: zip,
      current_user: current_user == user,
    }

    case kind
    when :public
      basic
    when :private
      basic.merge(
        {
          registration: registration,
          full_address: full_address,
          token: token,
        }
      )
    else
      raise "kind #{kind} not surported"
    end
  end

  def to_param
    token
  end

  private

  def defaults
    self.token ||= SecureRandom.hex(16)
  end
end
