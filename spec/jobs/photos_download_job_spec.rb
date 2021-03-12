require 'spec_helper'

describe PhotosDownloadJob do
  let(:bulk_upload) { Fabricate.create(:bulk_upload, shared_album_url: 'https://photos.app.goo.gl/85akvN1q3xxcT4Hu9') }

  # context "perform" do
  #   it "download the archive from google photos" do
  #     expect { PhotosDownloadJob.perform_now(bulk_upload) }.to change { bulk_upload.photos.count }.by(1)
  #   end
  #
  #   it "handles broken urls" do
  #     bulk_upload = Fabricate.create(:bulk_upload, shared_album_url: 'https://photos.app.goo.gl/not_found')
  #     expect { PhotosDownloadJob.perform_now(bulk_upload) }.to change { bulk_upload.status }.from('open').to('error')
  #
  #     bulk_upload = Fabricate.create(:bulk_upload, shared_album_url: 'https://www.weg.li')
  #     expect { PhotosDownloadJob.perform_now(bulk_upload) }.to change { bulk_upload.status }.from('open').to('error')
  #   end
  # end
end
