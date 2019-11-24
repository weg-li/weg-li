class Reply < ApplicationRecord
  belongs_to :notice

  validates :sender, :subject, :content, presence: true
end
