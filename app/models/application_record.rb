# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  strip_attributes

  def self.human_enum_name(enum_name, enum_value)
    I18n.t(
      "activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}",
    )
  end

  def translate_enum(enum_name)
    I18n.t(
      "activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{send(enum_name)}",
    )
  end
end
