# frozen_string_literal: true

class Api::VehicleCountriesController < ActionController::Base
  include Swagger::Blocks

  swagger_schema :VehicleCountry do
    key :type, :object
    key :required, %i[iso_code vehicle_sign owi21_plate_type]
    %i[iso_code vehicle_sign owi21_plate_type].each { |name| property(name) { key :type, :string } }
  end

  swagger_path "/vehicle_countries" do
    operation :get do
      key :summary, "Get registration countries and OWI21 vehicle codes"
      key :tags, ["notice"]
      key :security, []
      response 200 do
        key :description, "Public country catalog"
        schema do
          key :type, :array
          items { key :$ref, :VehicleCountry }
        end
      end
    end
  end

  def index
    response.headers["Cache-Control"] = "public, max-age=300"
    render json: VehicleCountry.records.values.map(&:to_h)
  end
end
