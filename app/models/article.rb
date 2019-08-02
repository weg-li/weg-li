class Article < ActiveRecord::Base
  PERIODS = {
    'this year'   => 1.year.ago,
    'this month'  => 1.month.ago,
    'this week'   => 1.week.ago,
  }

  validates :headline, :content, presence: true

  belongs_to :user

  scope :active, -> { where('published_at <= ?', Time.now).order('published_at DESC') }

  %w(de en).each do |locale|
    %w(headline content).each do |field|
      define_method "#{locale}_#{field}" do
        (self[field] || {})[locale]
      end
      define_method "#{locale}_#{field}=" do |data|
        self[field] ||= {}
        self[field][locale] = data
      end
    end
  end

  def title
    (headline || {})[I18n.locale.to_s]
  end

  def body
    (content || {})[I18n.locale.to_s]
  end

  def to_param
    "#{title.parameterize}-#{id}"
  end

  def to_label
    "#{title} (#{id})"
  end

  def self.facets
    tags = self.active.pluck(:tags)
    tags_count  = tags.flatten.each_with_object(Hash.new(0)) { |tag, counts| counts[tag] += 1 }
    dates_count = PERIODS.each_with_object(Hash.new(0)) { |(name, start), counts| counts[name] += Article.where(published_at: (start..Time.now)).count }
    {
      tags:  tags_count,
      dates: dates_count,
    }
  end

  def self.from_param(param)
    self.find(param[/-(\d*)\z/, 1])
  end

  def self.tagged_with(tag)
    where('? = ANY (tags)', tag)
  end

  def self.in_period(period)
    where('published_at > ?', PERIODS[period])
  end
end
