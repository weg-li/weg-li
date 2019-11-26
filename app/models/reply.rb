class Reply < ApplicationRecord
  belongs_to :notice
  belongs_to :action_mailbox_inbound_email, class_name: 'ActionMailbox::InboundEmail', optional: true

  validates :sender, :subject, :content, presence: true
end
