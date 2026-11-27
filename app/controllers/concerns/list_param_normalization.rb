# frozen_string_literal: true

module ListParamNormalization
  extend ActiveSupport::Concern

  protected

  def normalize_list_param(value)
    case value
    when String
      value.split(/[;,|]/).map(&:strip).reject(&:blank?)
    when Array
      value.reject(&:blank?)
    else
      []
    end
  end
end
