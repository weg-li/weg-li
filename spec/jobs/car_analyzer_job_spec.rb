require 'spec_helper'

describe CarAnalyzerJob do
  context "perform" do
    let(:notice) { Fabricate.create(:notice) }

    it "should analyze the image with yolo" do
      job = CarAnalyzerJob.new
      stub_request(:post, "https://weg-li-car-ml.onrender.com/").to_return(status: 200, body: "{\"suggestions\":{}}", headers: {})

      expect {
        job.perform(notice)
      }.to change {
        notice.data_sets.count
      }.by(1)
    end

    it "should analyze the image with vision if yolo fails" do
      job = CarAnalyzerJob.new
      this = self
      job.define_singleton_method(:annotator) { this }
      def job.handle_ml(notice)
        raise HTTP::TimeoutError
      end

      expect {
        job.perform(notice)
      }.to change {
        notice.data_sets.count
      }.by(1)
    end
  end

  def annotate_object(key)
    with_fixture('annotate') { Annotator.new.annotate_object(key) }
  end
end
