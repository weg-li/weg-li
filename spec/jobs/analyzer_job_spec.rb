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
      annotator = instance_double(GeminiAnnotator, annotate_object: { registrations: ["registration"], brands: ["brand"], colors: ["color"] })
      allow(job).to receive(:gemini_annotator).and_return(annotator)

      expect do
        job.perform(notice)
      end.to change {
        notice.data_sets.count
      }.by(3)
    end

    it "should continue if there is a timeout" do
      job = AnalyzerJob.new
      annotator = instance_double(GeminiAnnotator)
      expect(annotator).to receive(:annotate_object).and_raise(HTTP::TimeoutError.new("execution expired"))
      allow(job).to receive(:gemini_annotator).and_return(annotator)

      expect do
        job.perform(notice)
      end.to change {
        notice.data_sets.count
      }.by(2)
    end

    it "should analyze the image without gemini" do
      job = AnalyzerJob.new
      notice.user.update!(analyzer: "no_analyzer")

      expect do
        job.perform(notice)
      end.to change {
        notice.data_sets.count
      }.by(2)
    end
  end
end
