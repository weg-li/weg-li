# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  strip_attributes

  def self.human_enum_name(enum_name, enum_value, default: nil)
    return default if enum_value.blank?

    I18n.t("#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}", scope: "activerecord.attributes")
  end

  def translate_enum(enum_name, default: nil)
    self.class.human_enum_name(enum_name, send(enum_name), default:)
  end
end
