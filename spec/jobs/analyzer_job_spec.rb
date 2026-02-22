# frozen_string_literal: true

require "spec_helper"

describe AnalyzerJob do
  context "perform" do
    let(:notice) { Fabricate.create(:notice) }

    before do
      stub_request(:get, /images\.weg\.li/).to_return(status: 200, body: file_fixture("mercedes.jpg").read)
    end

    it "should analyze the image" do
      job = AnalyzerJob.new
      this = self
      job.define_singleton_method(:gemini_annotator) { |_model| this }

      expect do
        job.analyze(notice)
      end.to change {
        notice.data_sets.count
      }.by(3)
    end
  end

  def annotate_object(key)
    { key: key, value: "value" }
  end
end
