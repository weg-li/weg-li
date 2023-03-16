# frozen_string_literal: true

class Export < ApplicationRecord
  enum export_type: { notices: 0, photos: 1, profiles: 2 }

  validates :export_type, :interval, presence: true

  has_one_attached :archive

  scope :for_public, -> { notices }
  scope :for_studis, -> { not_notices }

  def header
    case export_type.to_sym
    when :notices
      %i[date tbnr street city zip latitude longitude]
    when :profiles
      %i[date user_id tbnr street city zip latitude longitude severity]
    when :photos
      %i[photo_uri date registration tbnr brand color]
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
    "#{export_type} #{interval}"
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
    Notice.shared.with_attached_photos.select(%i[id date registration tbnr brand color])
  end

  def photos_entries(notice)
    data = %i[date registration tbnr brand color].map { |key| notice.send(key) }
    notice.photos.map { |photo| [Annotator.bucket_uri(photo.key)] + data }
  end
end
