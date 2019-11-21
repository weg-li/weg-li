class User < ActiveRecord::Base
  include Bitfields
  bitfield :flags, 1 => :hide_public_profile, 2 => :disable_reminders

  enum access: {disabled: -99, ghost: -1, user: 0, community: 1, admin: 42}

  geocoded_by :full_address
  after_validation :geocode
  before_validation :defaults

  has_many :bulk_uploads, -> { order('created_at DESC') }, dependent: :destroy
  has_many :notices, -> { order('created_at DESC') }, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :photos_attachments, through: :notices

  accepts_nested_attributes_for :authorizations

  validates :nickname, :email, :token, :name, :street, :zip, :city, presence: true
  validates :email, :token, uniqueness: true
  validates :time_zone, inclusion: {in: ActiveSupport::TimeZone.all.map(&:name)}, allow_nil: true, allow_blank: true

  scope :since, -> (date) { where('users.created_at > ?', date) }
  scope :for_public, -> () { not_hide_public_profile }
  scope :active, -> () { where('access >= 0') }

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

  def full_address
    "#{street}, #{zip} #{city}, Deutschland"
  end

  def to_label
    "#{nickname} (#{email})"
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
