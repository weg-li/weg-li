class District < ActiveRecord::Base
  include Bitfields
  bitfield :flags, 1 => :email_hidden

  geocoded_by :geocode_address
  after_validation :geocode

  acts_as_api

  api_accessible :public_beta do |template|
    %i(name zip email prefix latitude longitude created_at updated_at).each { |key| template.add(key) }
  end

  validates :name, :zip, :email, presence: :true

  has_many :notices, foreign_key: :zip, primary_key: :zip

  def self.from_zip(zip)
    find_by(zip: zip)
  end

  def map_data
    {
      zoom: 13,
      latitude: latitude,
      longitude: longitude,
    }
  end

  def statistics(date = 100.years.ago)
    {
      notices: notices.since(date).count,
      users: User.where(id: notices.since(date).pluck(:user_id)).count,
    }
  end

  def geocode_address
    "#{zip}, #{name}, Deutschland"
  end

  def all_emails
    aliases.present? ? [email] + aliases : [email]
  end

  def display_name
    "#{email} (#{zip} #{name})"
  end

  def display_email
    anonymize_email(email)
  end

  def anonymize_email(email)
    return '-' unless email.present?

    return email unless email_hidden?

    address, domain = email.split('@')

    "#{address.first}#{'.' * (address.size - 1)}@#{domain}"
  end

  def display_aliases
    return '-' unless aliases.present?

    aliases.map {|email| anonymize_email(email) }.compact.join(', ')
  end

  def District.attach_prefix
    District.where(prefix: nil).limit(5000).each do |district|
      prefix = Vehicle.zip_to_prefix[district.zip]
      if prefix.present?
        district.update_attribute(:prefix, prefix)
      else
        Rails.logger.info("no match for #{district.name} #{district.zip}")
      end
    end
  end

  def District.attach_aliases
    {
      '80331' => ['pp-mue.muenchen.pi11@polizei.bayern.de'],
      '80333' => ['pp-mue.muenchen.pi12@polizei.bayern.de'],
      '80335' => ['pp-mue.muenchen.pi16@polizei.bayern.de'],
      '80336' => ['pp-mue.muenchen.pi14@polizei.bayern.de'],
      '80637' => ['pp-mue.muenchen.pi42@polizei.bayern.de'],
      '80687' => ['pp-mue.muenchen.pi41@polizei.bayern.de'],
      '80805' => ['pp-mue.muenchen.pi13@polizei.bayern.de'],
      '80809' => ['pp-mue.muenchen.pi43@polizei.bayern.de'],
      '80937' => ['pp-mue.muenchen.pi47@polizei.bayern.de'],
      '80997' => ['pp-mue.muenchen.pi44@polizei.bayern.de'],
      '81241' => ['pp-mue.muenchen.pi45@polizei.bayern.de'],
      '81373' => ['pp-mue.muenchen.pi15@polizei.bayern.de'],
      '81477' => ['pp-mue.muenchen.pi29@polizei.bayern.de'],
      '81541' => ['pp-mue.muenchen.pi21@polizei.bayern.de'],
      '81549' => ['pp-mue.muenchen.pi23@polizei.bayern.de'],
      '81675' => ['pp-mue.muenchen.pi22@polizei.bayern.de'],
      '81737' => ['pp-mue.muenchen.pi24@polizei.bayern.de'],
      '81829' => ['pp-mue.muenchen.pi25@polizei.bayern.de'],
      '80636' => ['pp-mue.muenchen.pi42@polizei.bayern.de'],
      '80639' => ['pp-mue.muenchen.pi41@polizei.bayern.de'],
      '80935' => ['pp-mue.muenchen.pi43@polizei.bayern.de'],
      '80995' => ['pp-mue.muenchen.pi44@polizei.bayern.de', 'pp-mue.muenchen.pi43@polizei.bayern.de'],
      '80993' => ['pp-mue.muenchen.pi44@polizei.bayern.de'],
    }.each do |zip, aliases|
      Rails.logger.info("updating #{zip} with #{aliases}")
      District.from_zip(zip).update!(aliases: aliases)
    end
  end
end
