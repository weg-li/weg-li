# frozen_string_literal: true

module Incompletable
  extend ActiveSupport::Concern

  included do
    before_save { self.incomplete = !valid? }

    def save_incomplete!
      valid? ? save! : save!(validate: false)
    end

    def complete?
      !incomplete?
    end

    scope :incomplete, -> { where(incomplete: true) }
    scope :complete, -> { where(incomplete: false) }
  end
end
