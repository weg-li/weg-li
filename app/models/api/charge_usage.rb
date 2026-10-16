# frozen_string_literal: true

class Api::ChargeUsage
  include Swagger::Blocks

  swagger_schema :ChargeUsageEntry do
    key :required, %i[tbnr count]
    property :tbnr do
      key :type, :string
    end
    property :count do
      key :type, :integer
      key :format, :int64
      key :minimum, 0
    end
    property :last_used_at do
      key :type, :string
      key :format, :"date-time"
      key :"x-nullable", true
      key :description, "Personal usage only: latest COALESCE(sent_at, created_at), or null if neither timestamp is available"
    end
  end

  swagger_schema :GlobalChargeUsage do
    key :required, %i[scope period generated_at charges]
    property :scope do
      key :type, :string
      key :enum, ["shared_notices"]
    end
    property :period do
      key :type, :string
      key :enum, ["all_time"]
    end
    property :generated_at do
      key :type, :string
      key :format, :"date-time"
      key :description, "Time the aggregate was calculated; cached on demand for one hour with a one-minute stale-cache grace period"
    end
    property :charges do
      key :type, :array
      key :description, "Every active catalog TBNR, including zero counts, ordered by count descending then TBNR"
      items { key :$ref, :ChargeUsageEntry }
    end
  end

  swagger_schema :PersonalChargeUsage do
    key :required, %i[scope period charges]
    property :scope do
      key :type, :string
      key :enum, ["shared_notices"]
    end
    property :period do
      key :type, :string
      key :enum, ["all_time"]
    end
    property :charges do
      key :type, :array
      key :description, "All nonblank TBNRs used in this user's shared notices, including historical codes; no top-N cutoff"
      items { key :$ref, :ChargeUsageEntry }
    end
  end
end
