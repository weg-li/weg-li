require 'spec_helper'

describe AnalyzerJob do
  context "perform" do
    let(:notice) { Fabricate.create(:notice) }

    it "should analyze the image with yolo" do
      job = AnalyzerJob.new
      stub_request(:post, "https://weg-li-car-ml.onrender.com/").to_return(status: 200, body: "{\"suggestions\":{}}", headers: {})

      expect {
        job.analyze(notice)
      }.to change {
        notice.data_sets.count
      }.by(3)
    end

    it "should analyze the image with vision if yolo fails" do
      job = AnalyzerJob.new
      this = self
      job.define_singleton_method(:annotator) { this }
      def job.handle_ml(notice)
        raise HTTP::TimeoutError
      end

      expect {
        job.analyze(notice)
      }.to change {
        notice.data_sets.count
      }.by(3)
    end
  end

  def annotate_object(key)
    with_fixture('annotate') { Annotator.new.annotate_object(key) }
  end

  context "helpers" do
    it "parses filenames as dated" do
      expect(AnalyzerJob.time_from_filename('IMG_20190929_164947.jpg').to_s).to eql('2019-09-29 16:49:47 +0200')
      expect(AnalyzerJob.time_from_filename('photo_2019-08-22_21-57-26.jpg').to_s).to eql('2019-08-22 21:57:26 +0200')
    end
  end
end
