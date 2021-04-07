require 'spec_helper'

describe ActiveStorage::Blob do
  it "sets a key with a file extension" do
    blob = ActiveStorage::Blob.new(filename: 'uschi.jpg')

    expect {
      blob.valid?
    }.to change {
      blob[:key]
    }.from(nil)
    expect(blob.key).to match(/\.jpg/)
  end
end

describe ActiveStorage::Representations::RedirectController, type: :request do
  it "sends a retry when not processed" do
    notice = Fabricate(:notice)

    expect {
      get rails_storage_redirect_url(notice.photos.first.variant({resize: "200x200", quality: '90', auto_orient: true}))
    }.to have_enqueued_job(ThumbnailerJob)

    expect(response).to be_a_redirect
    expect(response.headers['Cache-Control']).to eql('no-store')
    expect(response.headers['Retry-After']).to eql(2)
  end
end
