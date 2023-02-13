# frozen_string_literal: true

require "spec_helper"

describe Scheduled::GeocodingCleanupJob do
  context "perform" do
    it "should fixup geocoding" do
      notice = Fabricate.create(:notice, latitude: -30)

      expect do
        Scheduled::GeocodingCleanupJob.perform_now
      end.to(change { notice.reload.latitude })
    end
  end
end
