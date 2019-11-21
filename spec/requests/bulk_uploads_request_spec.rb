require 'spec_helper'

describe 'bulk_uploads', type: :request do
  let(:user) { Fabricate(:user) }
  let(:bulk_upload) { Fabricate(:bulk_upload, user: user) }

  before do
    login(user)
  end

  context "GET :new" do
    it "renders the page" do
      get new_bulk_upload_path

      expect(response).to be_successful
    end
  end

  context "POST :create" do
    let(:params) {
      {
        bulk_upload: {
          photos: [fixture_file_upload(Rails.root.join('spec/support/assets/mercedes.jpg'), 'image/jpeg')],
        }
      }
    }

    it "creates a bulk_upload with given params" do
      expect {
        expect {
          post bulk_uploads_path, params: params
        }.to change { user.bulk_uploads.count }.by(1)
      }.to have_enqueued_job(BulkUploadJob)
    end
  end

  context "GET :edit" do
    it "renders the page" do
      get edit_bulk_upload_path(bulk_upload)

      expect(response).to be_successful
    end
  end

  context "PATCH :update" do
    it "assigns images for notices" do
      params = {
        bulk_upload: {
          photos: [bulk_upload.photos.first.id],
        },
      }
      expect {
        expect {
          patch bulk_upload_path(bulk_upload), params: params
        }.to change { user.notices.count }.by(1)
      }.to have_enqueued_job(AnalyzerJob)

      expect(response).to be_a_redirect
    end

    it "assigns images a notice for each image on demand" do
      params = {
        one_per_photo: true,
        bulk_upload: { photos: [] },
      }
      expect {
        expect {
          patch bulk_upload_path(bulk_upload), params: params
        }.to change { user.notices.count }.by(1)
      }.to have_enqueued_job(AnalyzerJob)

      expect(response).to be_a_redirect
    end
  end

  context "DELETE :destroy" do
    it "should destroy the bulk_upload" do
      bulk_upload = Fabricate(:bulk_upload, user: user)

      expect {
        delete bulk_upload_path(bulk_upload)
      }.to change { user.bulk_uploads.count }.by(-1)
    end
  end
end
