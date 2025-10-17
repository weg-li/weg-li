# frozen_string_literal: true

class Notice < ApplicationRecord
  # broadcasts_refreshes

  include Statisticable
  ADDRESS_ZIP_PATTERN = /.+(\d{5}).+/

  extend TimeSplitter::Accessors
  split_accessor :start_date, :end_date

  include Bitfields
  bitfield :flags,
           1 => :vehicle_empty,
           2 => :hazard_lights,
           4 => :expired_tuv,
           8 => :expired_eco,
           16 => :over_2_8_tons

  def self.details
    bitfields[:flags].keys
  end

  acts_as_api

  api_accessible(:public_beta) do |api|
    api.add(:token)
    api.add(:status)
    api.add(:street)
    api.add(:city)
    api.add(:zip)
    api.add(:latitude)
    api.add(:longitude)
    api.add(:registration)
    api.add(:color)
    api.add(:brand)
    api.add(:charge)
    api.add(:tbnr)
    api.add(:start_date)
    api.add(:end_date)
    api.add(:note)
    api.add(:photos)
    api.add(:created_at)
    api.add(:updated_at)
    api.add(:sent_at)
    api.add(:attachments, as: :photos)
    Notice.bitfields[:flags].each_key { |key| api.add(key) }
  end

  include Incompletable

  geocoded_by :geocode_address, language: proc { |_model| I18n.locale }, no_annotations: true

  before_validation :defaults

  after_validation :geocode, if: :do_geocoding?
  after_validation :postgisify

  enum :status, { open: 0, disabled: 1, analyzing: 2, shared: 3 }

  belongs_to :user
  belongs_to :charge, -> { order(valid_from: :desc) }, optional: true, foreign_key: :tbnr, primary_key: :tbnr
  # TODO: (PS) merge with brand ID
  belongs_to :branddd, class_name: "Brand", optional: true, foreign_key: :brand, primary_key: :name
  belongs_to :district, optional: true, foreign_key: :zip, primary_key: :zip
  belongs_to :bulk_upload, optional: true
  has_many_attached :photos
  has_many :replies, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :data_sets, -> { order(created_at: :desc) }, dependent: :destroy, as: :setable

  normalizes :zip, with: lambda(&:strip)

  validates :photos, :registration, :street, :city, :start_date, :end_date, :charge, presence: true
  validates :zip, presence: true, zip: true
  validates :tbnr, length: { is: 6 }
  validates :token, uniqueness: true
  validate :validate_creation_date, on: :create
  validate :validate_date
  validate :validate_duration

  scope :since, ->(date) { where("notices.created_at > ?", date) }
  scope :for_public, -> { where.not(status: :disabled) }
  # REM: (PS) \W in live postgres is matching umlauts for whatever reason.
  scope :search, ->(term) { where("regexp_replace(notices.registration, '(\s|-)', '', 'g') ILIKE :term", term: "%#{term.gsub(/(\s|-)/, '')}%") }
  scope :preselect, -> { shared.limit(3) }
  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  def self.for_reminder
    open
      .joins(:user)
      .where(start_date: [(21.days.ago.beginning_of_day)..(14.days.ago.end_of_day)])
      .merge(User.not_disable_reminders)
      .merge(User.active)
  end

  def self.from_param(token)
    find_by!(token:)
  end

  def self.from_email_address(email)
    token = email[/^([^-]+)@.+/, 1]
    find_by!(token:)
  end

  # TODO: (PS) remove
  def self.statistics
    Homepage.statistics
  end

  def self.yearly_statistics(year, limit, base_scope: Notice.shared)
    notices = base_scope.reorder(nil)
    if year.present?
      notices =
        notices.where(
          start_date: (Time.new(year)..Time.new(year).end_of_year),
        )
    end
    {
      count: notices.count,
      active: notices.distinct(:user_id).pluck(:user_id).count,
      grouped_states:
        notices
          .joins(:district)
          .select("count(districts.state) as state_count, districts.state")
          .group("districts.state")
          .order(state_count: :desc)
          .limit(limit)
          .to_a,
      grouped_cities:
        notices
          .select("count(city) as city_count, city")
          .group(:city)
          .order(city_count: :desc)
          .limit(limit)
          .to_a,
      grouped_zips:
        notices
          .select("count(zip) as zip_count, zip")
          .group(:zip)
          .order(zip_count: :desc)
          .limit(limit)
          .to_a,
      grouped_charges:
        notices
          .select("count(tbnr) as tbnr_count, tbnr")
          .group(:tbnr)
          .order(tbnr_count: :desc)
          .limit(limit)
          .to_a,
      grouped_brands:
        notices
          .select("count(brand) as brand_count, brand")
          .where("brand != ''")
          .group(:brand)
          .order(brand_count: :desc)
          .limit(limit)
          .to_a,
      grouped_registrations:
        notices
          .select("count(registration) as registration_count, registration")
          .group(:registration)
          .order(registration_count: :desc)
          .limit(limit)
          .to_a,
    }
  end

  def photos=(attachables)
    attachables = Array(attachables).compact_blank
    # BC config.active_storage.replace_on_assign_to_many set to true before upgrading
    if attachables.any?
      attachment_changes["photos"] = ActiveStorage::Attached::Changes::CreateMany.new("photos", self, photos.blobs + attachables)
    end
  end

  def wegli_email
    "#{token}@anzeige.weg.li"
  end

  def duplicate!
    notice = dup
    notice.token = nil
    notice.status = :open
    notice.photos.attach(photos.map(&:blob))
    notice.save_incomplete!
    notice.reload
  end

  def mark_shared!
    update!(status: :shared, sent_at: Time.now)
  end

  def self.mark_shared
    update(status: :shared, sent_at: Time.now)
  end

  def analyze!
    self.status = :analyzing
    save_incomplete!

    AnalyzerJob.perform_later(self)
    # AnalyzerJob.set(wait: 1.second).perform_later(self)
  end

  def owi21_args
    args = {
      GMK: district.ags,
      GUID: guid,
      Gemarkung: city,
      Tatort: full_location,
      Tattag: start_date.strftime("%Y-%m-%d"),
      Tatzeit: start_date.strftime("%H:%M"),
      Beweis_Schluessel_1: "1",
      Beweis_Schluessel_2: "4",
      Beteiligung_Schluessel: "2", # Halterin/Halter
      Fahrzeugtyp_Schluessel: "D", # PKW
      KFZ_Kennzeichen: Vehicle.normalize(registration, text_divider: "-"),
      KFZ_Kennzeichen_Merkmal: "1", # FZV
    }
    if district.ags == "06440008" # Friedberg (Hessen)
      args[:AnwenderNr] = "997"
      args[:Sachgebiet_Schluessel] = "2"
    end
    args
  end

  def date_doubles
    return false if registration.blank?

    user
      .notices
      .where("DATE(start_date) = DATE(?)", start_date)
      .where(registration:)
      .where.not(id:)
  end

  def photo_doubles
    user
      .photos_attachments
      .joins(:blob)
      .where("active_storage_attachments.record_id != ?", id)
      .where(
        "active_storage_blobs.filename" =>
          photos.map { |photo| photo.filename.to_s },
      )
  end

  def apply_favorites(registrations)
    other =
      user
        .notices
        .shared
        .where(
          "REPLACE(registration, ' ', '') IN(?)",
          registrations.map { |registration| registration.gsub(/\s/, "") },
        )
        .order(created_at: :desc)
        .first

    if other
      self.registration = other.registration
      self.brand = other.brand if !brand? && other.brand?
      self.color = other.color if !color? && other.color?
      self.location = other.location if !location? && other.location?
      self.tbnr = other.tbnr if !tbnr? && other.tbnr?
      self.flags = other.flags if !flags? && other.flags?
      self.note = other.note if !note? && other.note?
    end
  end

  def self.nearest_tbnrs(latitude, longitude, distance = 50, count = 10)
    sql =
      "
    SELECT
      tbnr,
      COUNT(tbnr) as count,
      SUM(ST_DistanceSphere(lonlat::geometry, ST_MakePoint($1, $2))) as distance,
      SUM(ST_DistanceSphere(lonlat::geometry, ST_MakePoint($1, $2))) / COUNT(tbnr) as diff
    FROM notices
    WHERE
      status = 3
      AND created_at > (CURRENT_DATE - INTERVAL '6 months')
      AND ST_DWithin(lonlat::geography, ST_MakePoint($1, $2), $3)
    GROUP BY tbnr
    ORDER BY diff
    LIMIT $4
    "
    binds = [longitude, latitude, distance, count]
    Notice.connection.exec_query(sql, "distance-quert", binds).to_a
  end

  def guid(format: :owi21)
    case format
    when :owi21
      token.gsub(/(\w{8})(\w{4})(\w{4})(\w{4})(\w{12})(.*)/, "\\1-\\2-\\3-\\4-\\5").upcase
    else
      token
    end
  end

  def meta
    photos.map(&:metadata).to_json
  end

  def coordinates?
    latitude? && longitude?
  end

  def coordinates_missing?
    !coordinates?
  end

  def do_geocoding?
    coordinates_missing? && zip? && city? && street?
  end

  def postgisify
    self.lonlat = "SRID=4326;POINT(#{longitude} #{latitude})" if coordinates?
  end

  def distance_too_large?
    return false if coordinates_missing?
    return false if district.blank?

    Geo.distance(self, district) > Geo::MAX_DISTANCE
  end

  def point
    [latitude, longitude]
  end

  def handle_geocoding
    if coordinates?
      result = self.class.geocode([latitude, longitude])
      if result.present?
        self.zip = result[:zip]
        self.city = result[:city]
        self.street = result[:street]
      end
    end
  end

  def self.geocode(coords)
    results = Geocoder.search(coords)
    if results.present?
      best_result = results.first

      geocode_data(best_result)
    end
  end

  def self.geocode_data(result)
    {
      latitude: result.latitude,
      longitude: result.longitude,
      zip: result.postal_code,
      city: result.city || result.state,
      street: "#{result.street} #{result.house_number}".strip,
    }
  end

  def dates_from_photos
    date_times = data_sets.select(&:exif?).map(&:date_time).compact.uniq
    if date_times.blank?
      date_times =
        photos
          .map { |photo| AnalyzerJob.time_from_filename(photo.filename.to_s) }
          .compact
          .uniq
    end
    date_times.sort
  end

  def file_name(extension = :pdf, prefix: nil)
    "#{"#{prefix}_" if prefix}#{start_date.strftime('%Y%m%d_%H%M')}_#{registration.parameterize.upcase}.#{extension}"
  end

  def full_address
    "#{street}, #{zip} #{city}"
  end

  def full_location
    "#{location_and_address}, #{zip} #{city}"
  end

  def location_and_address
    [street, location].reject(&:blank?).join(", ")
  end

  def geocode_address
    # https://github.com/OpenCageData/opencagedata-misc-docs/blob/master/query-formatting.md
    "#{street.split(',').first}, #{zip}, #{city}, Deutschland"
  end

  def map_data(kind = :public)
    basic = { latitude:, longitude:, tbnr:, start_date:, zip: }

    case kind
    when :public
      basic
    when :private
      basic.merge({ registration:, full_address:, token: })
    else
      raise "kind #{kind} not surported"
    end
  end

  def to_param
    token
  end

  private

  def attachments
    photos.map do |photo|
      redirect_url = Rails.application.routes.url_helpers.rails_blob_url(photo, Rails.configuration.action_mailer.default_url_options)
      { filename: photo.filename, url: redirect_url }
    end
  end

  def validate_date
    errors.add(:start_date, :invalid) if start_date.to_i > Time.zone.now.to_i
    errors.add(:end_date, :invalid) if start_date.to_i > end_date.to_i
  end

  def validate_creation_date
    errors.add(:start_date, :invalid) if start_date.to_i < 3.month.ago.to_i
  end

  def validate_duration
    errors.add(:end_date, :future) if end_date.to_i > Time.zone.now.to_i
  end

  def defaults
    self.token ||= SecureRandom.hex(16)
  end
end
