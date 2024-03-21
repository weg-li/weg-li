# frozen_string_literal: true

class Export < ApplicationRecord
  enum export_type: { notices: 0 }
  enum file_extension: { csv: 0, json: 1 }

  validates :export_type, :interval, presence: true

  has_one_attached :archive
  belongs_to :user, optional: true

  scope :for_public, -> { where(user_id: nil) }

  acts_as_api

  api_accessible(:public_beta) do |api|
    api.add(:export_type)
    api.add(:interval)
    api.add(:file_extension)
    api.add(:created_at)
    api.add(:download)
  end

  def download
    redirect_url = Rails.application.routes.url_helpers.rails_blob_url(archive, Rails.configuration.action_mailer.default_url_options)
    { filename: archive.filename, url: redirect_url }
  end

  def header
    case export_type.to_sym
    when :notices
      %i[start_date end_date tbnr street city zip latitude longitude]
    when :profiles
      %i[start_date end_date user_id tbnr street city zip latitude longitude]
    when :photos
      %i[photo_uri start_date end_date registration tbnr brand color]
    else
      raise "unsupported type #{export_type}"
    end
  end

  def data(&block)
    scope = send("#{export_type}_scope")
    scope.in_batches do |batch|
      batch.each do |record|
        entries = send("#{export_type}_entries", record)
        entries.each { |data| block.call(data) }
      end
    end
  end

  def display_name
    "#{export_type} #{interval} #{(created_at || Date.today).year}"
  end

  private

  def notices_scope
    Notice.shared.select(header)
  end

  def notices_entries(notice)
    [header.map { |key| notice.send(key) }]
  end

  def profiles_scope
    Notice.shared.select(header)
  end

  def profiles_entries(notice)
    [header.map { |key| notice.send(key) }]
  end

  def photos_scope
    Notice.shared.with_attached_photos.select(%i[id start_date end_date registration tbnr brand color])
  end

  def photos_entries(notice)
    data = %i[start_date end_date registration tbnr brand color].map { |key| notice.send(key) }
    notice.photos.map { |photo| [Annotator.bucket_uri(photo.key)] + data }
  end
end
