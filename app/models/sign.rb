# frozen_string_literal: true

class Sign < ApplicationRecord
  validates :number, :description, presence: true

  acts_as_api

  api_accessible :public_beta do |template|
    %i[
      number
      description
      image
      created_at
      updated_at
    ].each { |key| template.add(key) }
  end

  def image
    "signs/#{number}.jpg.png"
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
