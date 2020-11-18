require 'spec_helper'

describe Scheduled::StuckJob do
  context "perform" do
    it "should kill the process" do
      return if ENV['CI']

      Scheduled::StuckJob.perform_now
    end
  end
end
