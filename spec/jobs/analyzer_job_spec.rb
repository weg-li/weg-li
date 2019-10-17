require 'spec_helper'

describe AnalyzerJob do
  let(:notice) { Fabricate.create(:notice) }

  context "perform" do
    it "should analyze the image" do
      job = AnalyzerJob.new
      this = self
      job.define_singleton_method(:annotator) { this }

      expect { job.perform(notice) }.to change { notice.reload.data }.from(NilClass).to(Hash)
    end

    it "should raise an error when not yet analyzed" do
      expect { AnalyzerJob.new.perform(notice) }.to raise_error(AnalyzerJob::NotYetAnalyzedError)
    end
  end

  def annotate_object(key)
    with_fixture('annotate') { Annotator.new.annotate_object(key) }
  end
end
