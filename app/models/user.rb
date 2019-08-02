class User < ActiveRecord::Base
  include Bitfields
  bitfield :flags, 1 => :disable_burned_emails

  enum access: {user: 0, admin: 42}

  before_validation :defaults

  has_many :notices, -> { order('created_at DESC') }, dependent: :destroy
  has_many :authorizations, dependent: :destroy
  has_many :articles, dependent: :destroy

  accepts_nested_attributes_for :authorizations

  validates :nickname, :email, :token, :name, :address, :district, presence: true
  validates :email, :token, uniqueness: true
  validates :time_zone, inclusion: {in: ActiveSupport::TimeZone.all.map(&:name)}, allow_nil: true, allow_blank: true

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

  def to_label
    "#{nickname} (#{email})"
  end

  def statistics
    {
      all: notices.count,
      incomplete: notices.incomplete.count,
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

    def find_by_session_or_cookies(session, cookies)
      find_by_id(session[:user_id]) || authenticated_with_token(*(cookies.signed[:remember_me] || ['', '']))
    end
  end
end
