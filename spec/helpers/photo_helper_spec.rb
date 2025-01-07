# frozen_string_literal: true

require "spec_helper"

describe PhotoHelper do
  context "url_for_photo" do
    it "gives a proper url" do
      notice = Fabricate.create(:notice)
      photo = notice.photos.first

      expect(helper.url_for_photo(photo)).to eql("https://images.weg.li/cdn-cgi/image/width=1280,height=1280,fit=scale-down,metadata=none,quality=90/storage/#{photo.key}")
      expect(helper.url_for_photo(photo, metadata: true)).to eql("https://images.weg.li/cdn-cgi/image/width=1280,height=1280,fit=scale-down,metadata=keep,quality=90/storage/#{photo.key}")
      expect(helper.url_for_photo(photo, size: :original)).to match("/active_storage/blobs/redirect")
    end
  end
end
