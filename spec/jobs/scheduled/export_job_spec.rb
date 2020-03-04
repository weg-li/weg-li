require 'spec_helper'

describe Scheduled::ExportJob do
  context "perform" do
    it "should create an export" do
      Fabricate.create(:notice, status: :shared)

      expect {
        Scheduled::ExportJob.perform_now
      }.to change { Export.count }.by(1)
    end
  end
end
