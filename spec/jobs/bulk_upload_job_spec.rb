require 'spec_helper'

describe BulkUploadJob do
  let(:bulk_upload) { Fabricate.create(:bulk_upload, status: :processing) }

  context "perform" do
    it "should process the bulk-upload" do
      expect {
        BulkUploadJob.perform_now(bulk_upload)
      }.to change { bulk_upload.status }.from('processing').to('open')
    end
  end
end
