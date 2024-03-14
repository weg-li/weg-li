# frozen_string_literal: true

module Blockable
  extend ActiveSupport::Concern

  included do
    class_attribute :blockables, default: []
    validate :email_block_list

    def email_block_list
      return if email.blank?

      self.class.blockables.each do |blockable|
        if email.match(blockable)
          errors.add(:email, :invalid)
          break
        end
      end
    end
  end
end
