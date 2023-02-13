# frozen_string_literal: true

require "spec_helper"

describe BulkUpload do
  let(:bulk_upload) { Fabricate.build(:bulk_upload) }

  context "validation" do
    it "is valid" do
      expect(bulk_upload).to be_valid
    end
  end
end
