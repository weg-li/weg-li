class AddActionMailboxInboundEmailsToReply < ActiveRecord::Migration[6.0]
  def change
    add_reference(:replies, :action_mailbox_inbound_email)
  end
end
