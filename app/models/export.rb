class Export < ApplicationRecord
  enum export_type: {notices: 0}

  validates :export_type, :interval, presence: true

  has_one_attached :archive

  def notices_scope
    case export_type.to_sym
    when :notices
      Notice.shared
    else
      raise "unsupported type #{export_type}"
    end
  end

  def display_name
    "#{export_type} #{interval}"
  end
end
