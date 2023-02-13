# frozen_string_literal: true

require "spec_helper"

describe AnalyzerJob do
  context "perform" do
    let(:notice) { Fabricate.create(:notice) }

    it "should analyze the image" do
      job = AnalyzerJob.new
      this = self
      job.define_singleton_method(:annotator) { this }

      expect do
        job.analyze(notice)
      end.to change {
        notice.data_sets.count
      }.by(3)
    end
  end

  def annotate_object(key)
    with_fixture("annotate") { Annotator.new.annotate_object(key) }
  end

  context "helpers" do
    it "parses filenames as dated" do
      expect(AnalyzerJob.time_from_filename("IMG_20190929_164947.jpg").to_s).to eql("2019-09-29 16:49:47 +0200")
      expect(AnalyzerJob.time_from_filename("photo_2019-08-22_21-57-26.jpg").to_s).to eql("2019-08-22 21:57:26 +0200")
    end
  end
end
