require 'spec_helper'

describe ThumbnailerJob do
  let(:notice) { Fabricate.create(:notice) }

  context "perform" do
    it "should thumbnail the image" do
      blob = notice.photos.first.blob

      expect { ThumbnailerJob.perform_now(blob) }.to change { blob.analyzed? }.from(nil).to(true)
    end
  end
end
