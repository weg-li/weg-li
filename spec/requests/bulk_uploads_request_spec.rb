# frozen_string_literal: true

require "spec_helper"

describe "bulk_uploads", type: :request do
  let(:user) { Fabricate(:user) }
  let(:bulk_upload) { Fabricate(:bulk_upload, user:) }
  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/mercedes.jpg"), "image/jpeg") }

  before do
    login(user)
  end

  context "index" do
    it "index works" do
      get bulk_uploads_path

      expect(response).to be_ok
    end

    it "no filters" do
      get bulk_uploads_path

      assert_select("td", { count: 1, text: "Es wurden keine Uploads gefunden" })

      get bulk_uploads_path(filter: { status: bulk_upload.status })

      assert_select("td", { count: 0, text: "Es wurden keine Uploads gefunden" })

      get bulk_uploads_path(filter: { status: "importing" })

      assert_select("td", { count: 1, text: "Es wurden keine Uploads gefunden" })
    end
  end

  context "GET :new" do
    it "renders the page" do
      get new_bulk_upload_path

      expect(response).to be_successful
    end
  end

  context "POST :create" do
    let(:params) do
      { bulk_upload: { photos: [file] } }
    end

    it "creates a bulk_upload with given params" do
      expect do
        post bulk_uploads_path, params:
      end.to change { user.bulk_uploads.count }.by(1)
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
      expect do
        expect do
          patch bulk_upload_path(bulk_upload), params:
        end.to change { user.notices.count }.by(1)
      end.to have_enqueued_job(AnalyzerJob)

      expect(response).to be_a_redirect
    end

    it "updates the notice with photos" do
      params = {
        button: "upload",
        bulk_upload: { photos: [file] },
      }
      expect do
        patch bulk_upload_path(bulk_upload), params:
      end.to change { bulk_upload.reload.photos.size }.by(1)
    end

    it "assigns images a notice for each image on demand" do
      params = {
        one_per_photo: true,
        bulk_upload: { photos: [] },
      }
      expect do
        expect do
          patch bulk_upload_path(bulk_upload), params:
        end.to change { user.notices.count }.by(1)
      end.to have_enqueued_job(AnalyzerJob)

      expect(response).to be_a_redirect
    end
  end

  context "POST :import" do
    it "imports images from url" do
      params = {
        bulk_upload: {
          shared_album_url: "https://photos.app.goo.gl/X4KX7AXNjXXu69Uf9",
        },
      }
      expect do
        expect do
          post import_bulk_uploads_path, params:
        end.to change { user.bulk_uploads.count }.by(1)
      end.to have_enqueued_job(PhotosDownloadJob)

      expect(response).to be_a_redirect
    end
  end

  context "PATCH :purge" do
    it "removes an image from a bulk_upload" do
      expect do
        patch purge_bulk_upload_path(bulk_upload, photo_id: bulk_upload.photos.first.id)

        expect(response).to be_redirect
      end.to have_enqueued_job(ActiveStorage::PurgeJob)
    end
  end

  context "DELETE :destroy" do
    it "should destroy the bulk_upload" do
      bulk_upload = Fabricate(:bulk_upload, user:)

      expect do
        delete bulk_upload_path(bulk_upload)
      end.to change { user.bulk_uploads.count }.by(-1)
    end
  end
end
