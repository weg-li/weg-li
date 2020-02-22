class Reply < ApplicationRecord
  belongs_to :notice
  belongs_to :action_mailbox_inbound_email, class_name: 'ActionMailbox::InboundEmail', optional: true

  validates :sender, :subject, :content, presence: true

  scope :search, -> (term) { joins(:notice).where('subject ILIKE :term OR content ILIKE :term OR sender ILIKE :term OR notices.registration ILIKE :term', term: "%#{term}%") }
end
