# frozen_string_literal: true

class Api::Charge < Charge
  include Swagger::Blocks

  swagger_schema :Charge do
    property :tbnr do
      key :type, :string
      key :pattern, '^\d{6}$'
    end
    property :description do
      key :type, :string
    end
    property :fine do
      key :type, :number
      key :format, :float
    end
    property :bkat do
      key :type, :string
    end
    property :penalty do
      key :type, :string
    end
    property :fap do
      key :type, :string
    end
    property :points do
      key :type, :string
    end
    property :valid_from do
      key :type, :string
      key :format, :"date-time"
    end
    property :valid_to do
      key :type, :string
      key :format, :"date-time"
    end
    property :implementation do
      key :type, :string
    end
    property :classification do
      key :type, :string
    end
    property :rule_id do
      key :type, :string
    end
    property :table_id do
      key :type, :string
    end
    property :required_refinements do
      key :type, :string
    end
    property :max_fine do
      key :type, :string
    end
    property :created_at do
      key :type, :string
      key :format, :"date-time"
    end
    property :updated_at do
      key :type, :string
      key :format, :"date-time"
    end
  end
end
