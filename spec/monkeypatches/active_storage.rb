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
