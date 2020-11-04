class User < ActiveRecord::Base
  include Statisticable
  include Bitfields
  bitfield :flags, 1 => :hide_public_profile, 2 => :disable_reminders, 4 => :disable_autoreply_notifications

  enum access: {disabled: -99, user: 0, community: 1, admin: 42}

  geocoded_by :geocode_address, language: Proc.new { |model| I18n.locale }, no_annotations: true
  after_validation :geocode
  after_validation :normalize
  before_validation :defaults

  has_many :bulk_uploads, -> { order('created_at DESC') }, dependent: :destroy
  has_many :notices, -> { order('created_at DESC') }, dependent: :destroy
  has_many :replies, -> { order('created_at DESC') }, through: :notices
  has_many :snippets, -> { order('created_at DESC') }
  has_many :authorizations, dependent: :destroy
  has_many :photos_attachments, through: :notices

  has_one_attached :signature

  accepts_nested_attributes_for :authorizations

  validates :nickname, :email, :token, :name, :street, :zip, :city, presence: true
  validates :email, :token, uniqueness: true

  scope :since, -> (date) { where('users.created_at > ?', date) }
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
  end
end
