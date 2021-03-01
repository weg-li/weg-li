class User < ActiveRecord::Base
  include Statisticable
  include Bitfields
  bitfield :flags, 1 => :hide_public_profile, 2 => :disable_reminders, 4 => :disable_autoreply_notifications

  enum access: {disabled: -99, user: 0, community: 1, studi: 2, admin: 42}

  geocoded_by :geocode_address, language: Proc.new { |model| I18n.locale }, no_annotations: true
  after_validation :geocode
  after_validation :normalize
  before_validation :defaults

  belongs_to :district, optional: true, foreign_key: :zip, primary_key: :zip
  has_many :bulk_uploads, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :notices, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :replies, -> { order(created_at: :desc) }, through: :notices
  has_many :snippets, -> { order(created_at: :desc) }
  has_many :authorizations, dependent: :destroy
  has_many :photos_attachments, through: :notices

  has_one_attached :signature

  accepts_nested_attributes_for :authorizations

  validates :nickname, :email, :token, :name, :street, :zip, :city, presence: true
  validates :email, :token, uniqueness: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validate :email_block_list

  def email_block_list
    errors.add(:email, :invalid) if email =~ /miucce.com/
  end

  scope :last_login_since, -> (date) { where('last_login > ?', date) }
  scope :since, -> (date) { where('created_at > ?', date) }
  scope :for_public, -> () { not_hide_public_profile }
  scope :active, -> () { where('access >= 0') }

  def self.from_param(token)
    find_by!(token: token)
  end

  def to_param
    token
  end

  def merge(source)
    User.transaction do
      source.notices.update_all(user_id: id)
      source.bulk_uploads.update_all(user_id: id)
    end
  end

  def validate!
    auth = authorizations.find_or_initialize_by(provider: 'email')
    auth.update! uid: email_uid

    self.update! validation_date: Time.now
  end

  def email_uid
    Digest::SHA256.new.hexdigest(email)
  end

  def validated?
    validation_date.present?
  end

  def geocode_address
    "#{street}, #{zip}, #{city}, Deutschland"
  end

  def full_address
    "#{"#{appendix}, " if appendix.present?}#{street}, #{zip} #{city}"
  end

  def first_name
    name[/(\S+)\s+(\S+)/, 1]
  end

  def last_name
    name[/(\S+)\s+(\S+)/, 2] || name
  end

  def street_without_housenumber
    street.gsub(/(.+) (\d+\w?)$/, '\1')
  end

  def housenumber
    street.gsub(/(.+) (\d+\w?)$/, '\2')
  end

  def to_label
    "#{nickname} (#{email})"
  end

  def public_nickname
    hide_public_profile? ? "Anonymous #{nickname.first.upcase}" : nickname
  end

  def wegli_email
    "#{token}@anzeige.weg-li.de"
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

  def statistics
    {
      all: notices.count,
      incomplete: notices.incomplete.count,
      open: notices.open.count,
      shared: notices.shared.count,
    }
  end

  def leaderboard_positions
    daily = Notice.since(Time.zone.now.beginning_of_day).group(:user_id).order(count_all: :desc).count
    weekly = Notice.since(Time.zone.now.beginning_of_week).group(:user_id).order(count_all: :desc).count
    monthly = Notice.since(Time.zone.now.beginning_of_month).group(:user_id).order(count_all: :desc).count
    yearly = Notice.since(Time.zone.now.beginning_of_year).group(:user_id).order(count_all: :desc).count
    alltime = Notice.group(:user_id).order(count_all: :desc).count

    @positions = [
      ['daily', daily.keys.index(id).to_i, daily[id].to_i, daily.first&.last.to_i],
      ['weekly', weekly.keys.index(id).to_i, weekly[id].to_i, weekly.first&.last.to_i],
      ['monthly', monthly.keys.index(id).to_i, monthly[id].to_i, monthly.first&.last.to_i],
      ['yearly', yearly.keys.index(id).to_i, yearly[id].to_i, yearly.first&.last.to_i],
      ['alltime', alltime.keys.index(id).to_i, alltime[id].to_i, alltime.first&.last.to_i],
    ]
  end

  private

  def normalize
    self.email = email.to_s.downcase
  end

  def defaults
    if new_record?
      self.token = SecureRandom.hex(16)
      self.api_token = SecureRandom.hex(32)
    end
  end

  class << self
    def authenticated_with_token(id, stored_token)
      user = find_by_id(id)
      user && user.token == stored_token ? user : nil
    end

    def add_project_data(data)
      data.stringify_keys!
      data.each do |id, hash|
        user = User.find(id)
        user.update!(project_access_token: hash[:access_token], project_user_id: hash[:user_id])
      end
    end
  end
end
