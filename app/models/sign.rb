# frozen_string_literal: true

class Sign < ApplicationRecord
  validates :number, :description, presence: true
  validates :number, uniqueness: true

  acts_as_api

  api_accessible :public_beta do |template|
    %i[
      number
      description
      url
      created_at
      updated_at
    ].each { |key| template.add(key) }
  end

  scope(:ordered, -> { order(number: :asc) })

  def grouped?
    number =~ /-/
  end

  def category?
    return false if grouped?

    !file.exist?
  end

  def parent_number
    return nil if category?

    number.split("-")[0]
  end

  def parent
    return nil if category?

    @parent ||= self.class.from_param(parent_number)
  end

  def image
    "signs/#{number}.jpg.png"
  end

  def url
    Rails.application.routes.url_helpers.sign_url(self, Rails.configuration.action_mailer.default_url_options.merge(format: :png))
  end

  def file
    Rails.root.join("app/assets/images", image)
  end

  def self.from_param(param)
    find_by!(number: param)
  end

  def to_param
    number
  end
end
