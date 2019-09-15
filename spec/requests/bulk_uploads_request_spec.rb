require 'spec_helper'

describe 'bulk_uploads', type: :request do
  let(:user) { Fabricate(:user) }

  context "create" do
    let(:params) {
      {
        bulk_upload: {
          photos: [fixture_file_upload(Rails.root.join('spec/support/assets/mercedes.jpg'), 'image/jpeg')],
        }
      }
    }
    before do
      login(user)
    end

    it "creates a bulk_upload with given params" do
      expect {
        post bulk_uploads_path, params: params
      }.to change { user.bulk_uploads.count }.by(1)
    end
  end

  context "destroy" do
    before do
      @bulk_upload = Fabricate(:bulk_upload, user: user)

      login(user)
    end

    it "should destroy the bulk_upload" do
      expect {
        delete bulk_upload_path(@bulk_upload)
      }.to change { user.bulk_uploads.count }.by(-1)
    end
  end
end
