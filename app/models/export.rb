class Export < ApplicationRecord
  enum export_type: {notices: 0, photos: 1}

  validates :export_type, :interval, presence: true

  has_one_attached :archive

  scope :for_public, -> () { notices }

  def header
    case export_type.to_sym
    when :notices
      [:date, :charge, :street, :city, :zip, :latitude, :longitude]
    when :photos
      [:photo_uri, :date, :registration, :charge, :brand, :color]
    else
      raise "unsupported type #{export_type}"
    end
  end


  def data(&block)
    case export_type.to_sym
    when :notices, :photos
      iterate_in_batches(&block)
    else
      raise "unsupported type #{export_type}"
    end
  end

  def display_name
    "#{export_type} #{interval}"
  end

  private

  def notices_scope
    Notice.shared.select(header)
  end

  def photos_scope
    Notice.shared.select([:id, :date, :registration, :charge, :brand, :color]).with_attached_photos
  end

  def notices_entries(notice)
    [header.map { |key| notice.send(key) }]
  end

  def photos_entries(notice)
    data = [:date, :registration, :charge, :brand, :color].map { |key| notice.send(key) }
    notice.photos.map { |photo| [Annotator.bucket_uri(photo.key)] + data }
  end

  def iterate_in_batches(&block)
    scope = send("#{export_type}_scope")
    scope.in_batches do |batch|
      batch.each do |record|
        entries = send("#{export_type}_entries", record)
        entries.each { |data| block.call(data) }
      end
    end
  end
end
