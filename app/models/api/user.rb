# frozen_string_literal: true

class Api::User
  include Swagger::Blocks

  swagger_schema :User do
    key :required, %i[name nickname statistics charge_usage]
    property :name do
      key :type, :string
    end
    property :nickname do
      key :type, :string
    end
    property :statistics do
      key :type, :object
      key :description, "Lifetime counts for the authenticated user, including archived notices; incomplete and archived overlap status counts"
      key :required, %i[notices open analyzing disabled shared incomplete archived]
      %i[notices open analyzing disabled shared incomplete archived].each do |name|
        property name do
          key :type, :integer
          key :format, :int64
          key :minimum, 0
        end
      end
    end
    property :charge_usage do
      key :$ref, :PersonalChargeUsage
    end
  end
end
