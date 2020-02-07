require 'spec_helper'

describe Scheduled::GeocodingCleanupJob do
  context "perform" do
    it "should fixup geocoding" do
      notice = Fabricate.create(:notice, latitude: -30)

      expect {
        Scheduled::GeocodingCleanupJob.perform_now
      }.to change {
        notice.reload.latitude
      }
    end
  end
end
