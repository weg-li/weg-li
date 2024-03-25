# frozen_string_literal: true

class Export < ApplicationRecord
  enum export_type: { notices: 0 }
  enum file_extension: { csv: 0 }

  validates :export_type, presence: true

  has_one_attached :archive
  belongs_to :user, optional: true

  scope :for_public, -> { where(user_id: nil) }

  acts_as_api

  api_accessible(:public_beta) do |api|
    api.add(:export_type)
    api.add(:file_extension)
    api.add(:created_at)
    api.add(:download)
  end

  def download
    redirect_url = Rails.application.routes.url_helpers.rails_blob_url(archive, Rails.configuration.action_mailer.default_url_options)
    { filename: archive.filename, url: redirect_url }
  end

  def data(&block)
    header = send("#{export_type}_fields")
    block.call(header)
    scope = send("#{export_type}_scope")
    scope.in_batches do |batch|
      batch.each do |record|
        entries = send("#{export_type}_entries", record)
        entries.each { |data| block.call(data) }
      end
    end
  end

  def display_name
    "#{export_type} #{file_extension} #{I18n.l((created_at || Time.now).utc, format: :short)}"
  end

  private

  def notices_fields
    if user.present?
      %i[token status registration brand color street city zip location tbnr note start_date end_date latitude longitude] + Notice.bitfields[:flags].keys
    else
      %i[start_date end_date tbnr street city zip latitude longitude]
    end
  end

  def notices_scope
    if user.present?
      user.notices
    else
      Notice.shared.select(notices_fields)
    end
  end

  def notices_entries(notice)
    [notices_fields.map { |key| notice.send(key) }]
  end
end
