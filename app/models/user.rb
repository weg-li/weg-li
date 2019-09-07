class User < ActiveRecord::Base
  include Bitfields
  bitfield :flags, 1 => :hide_public_profile

  enum access: {disabled: -99, ghost: -1, user: 0, community: 1, admin: 42}

  geocoded_by :address
  after_validation :geocode
  before_validation :defaults

  has_many :notices, -> { order('created_at DESC') }, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :articles, dependent: :destroy

  accepts_nested_attributes_for :authorizations

  validates :nickname, :email, :token, :name, :address, :district, presence: true
  validates :email, :token, uniqueness: true
  validates :time_zone, inclusion: {in: ActiveSupport::TimeZone.all.map(&:name)}, allow_nil: true, allow_blank: true

  scope :since, -> (date) { where('users.created_at > ?', date) }
  scope :for_public, -> () { not_hide_public_profile }

  def validate!
    update_attributes! validation_date: Time.now
  end

  def validated?
    validation_date.present?
  end

  def district=(district)
    self[:district] = district.to_s
  end

  def district
    District.by_name(self[:district])
  end

  def district_name
    self[:district]
  end

  def to_label
    "#{nickname} (#{email})"
  end

  def coordinates?
    latitude? && longitude?
  end

  def wegli_email
    "#{nickname.parameterize}+#{token}@anzeige.weg-li.de"
  end

  def map_data
    return district.map_data unless coordinates?

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
    end
  end

  class << self
    def authenticated_with_token(id, stored_token)
      user = find_by_id(id)
      user && user.token == stored_token ? user : nil
    end
  end
end
