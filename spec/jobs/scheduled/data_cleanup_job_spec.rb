# frozen_string_literal: true

require "spec_helper"

describe Scheduled::DataCleanupJob do
  context "perform" do
    it "should fixup geocoding" do
      Fabricate.create(:data_set, created_at: 7.month.ago)
      Fabricate.create(:data_set, created_at: 5.month.ago)

      expect do
        Scheduled::DataCleanupJob.perform_now
      end.to change(DataSet, :count).by(-1)
    end
  end
end
