# frozen_string_literal: true

require "spec_helper"

describe Scheduled::MaterializedViewUpdaterJob do
  context "perform" do
    it "should archive notices" do
      expect(Homepage.statistics[:districts]).to eql(0)
      Fabricate.create(:notice)
      expect(Homepage.statistics[:districts]).to eql(0)
      expect do
        Scheduled::MaterializedViewUpdaterJob.perform_now
      end.to change { Homepage.statistics[:districts] }.by(1)
    end
  end
end
