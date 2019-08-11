# frozen_string_literal: true

module Incompletable
  extend ActiveSupport::Concern

  included do
    before_save do
      self.incomplete = !valid?
    end

    def save_incomplete!
      if valid?
        save!
      else
        save!(validate: false)
      end
    end

    def complete?
      !incomplete?
    end

    scope :incomplete, -> { where(incomplete: true) }
    scope :complete, -> { where(incomplete: false) }
  end
end
