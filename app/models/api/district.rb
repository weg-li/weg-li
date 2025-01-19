# frozen_string_literal: true

class Api::District < District
  include Swagger::Blocks

  swagger_schema :District do
    property :name do
      key :type, :string
    end
    property :zip do
      key :type, :string
      key :pattern, '^\d{5}$'
    end
    property :email do
      key :type, :string
      key :pattern, '.+@.+\..+'
    end
    property :latitude do
      key :type, :number
      key :format, :float
    end
    property :longitude do
      key :type, :number
      key :format, :float
    end
    property :personal_email do
      key :type, :boolean
    end
    property :updated_at do
      key :type, :string
      key :format, :"date-time"
    end
    property :created_at do
      key :type, :string
      key :format, :"date-time"
    end
    property :aliases do
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :prefixes do
      key :type, :array
      items do
        key :type, :string
      end
    end
    property :parts do
      key :type, :array
      items do
        key :type, :string
      end
    end
  end
end
