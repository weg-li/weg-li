# frozen_string_literal: true

require "spec_helper"

describe "bulk_uploads", type: :request do
  let(:user) { Fabricate(:user) }
  let(:bulk_upload) { Fabricate(:bulk_upload, user:) }
  let(:file) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/mercedes.jpg"), "image/jpeg") }
  let(:zip) { Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/import.zip"), "application/zip") }

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

  context "GET :show" do
    def incomplete_notice(**attributes)
      Fabricate.build(:notice, user:, bulk_upload:, street: nil, **attributes).tap(&:save_incomplete!)
    end

    it "lists incomplete notices first and the rest below" do
      complete = Fabricate.create(:notice, user:, bulk_upload:, registration: "HH-CO 1")
      incomplete = incomplete_notice
      expect(incomplete).to be_incomplete

      get bulk_upload_path(bulk_upload)

      expect(response).to be_successful
      body = response.body
      expect(body.index("Unvollständige Meldungen (1)")).to be < body.index("Vollständige Meldungen (1)")
      expect(body.index("Vollständige Meldungen (1)")).to be < body.index(complete.registration)
      expect(body).to include(incomplete.registration)
    end

    it "lists the notices of each group in the order they were created" do
      later = Fabricate.create(:notice, user:, bulk_upload:, registration: "HH-LA 2", created_at: 1.hour.ago)
      earlier = Fabricate.create(:notice, user:, bulk_upload:, registration: "HH-EA 1", created_at: 2.hours.ago)

      get bulk_upload_path(bulk_upload)

      expect(response.body.index(earlier.registration)).to be < response.body.index(later.registration)
    end

    it "shows no group headings when all notices are in one group" do
      Fabricate.create(:notice, user:, bulk_upload:)

      get bulk_upload_path(bulk_upload)

      expect(response.body).not_to include("Vollständige Meldungen")

      incomplete_notice
      Notice.update_all(incomplete: true)

      get bulk_upload_path(bulk_upload)

      expect(response.body).not_to include("Unvollständige Meldungen")
      expect(response.body).not_to include("Vollständige Meldungen")
    end

    it "shows the plate of an incomplete notice when the group titles are visible" do
      Fabricate.create(:notice, user:, bulk_upload:)
      incomplete_notice(registration: "HH-IN 5")
      incomplete_notice(registration: nil)

      get bulk_upload_path(bulk_upload)

      assert_select("span.label-license", text: "HH-IN 5")
      assert_select("span.label-status-incomplete", 1)
      assert_select("th[scope=colgroup][colspan='5']", 2)
    end

    it "keeps the incomplete label when all notices are incomplete" do
      incomplete_notice(registration: "HH-IN 5")

      get bulk_upload_path(bulk_upload)

      assert_select("span.label-status-incomplete", 1)
      assert_select("span.label-license", 0)
    end

    it "renders a notice without start_date" do
      notice = incomplete_notice
      notice.update_columns(start_date: nil, end_date: nil)
      Fabricate.create(:notice, user:, bulk_upload:)

      get bulk_upload_path(bulk_upload)

      expect(response).to be_successful
      expect(response.body).to include("Unvollständige Meldungen (1)")
    end

    it "renders a bulk_upload without notices" do
      get bulk_upload_path(bulk_upload)
      expect(response).to be_successful

      get edit_bulk_upload_path(bulk_upload)
      expect(response).to be_successful
    end
  end

  context "GET :edit with notices" do
    it "lists incomplete notices first and the rest below" do
      Fabricate.create(:notice, user:, bulk_upload:)
      Fabricate.build(:notice, user:, bulk_upload:, street: nil).tap(&:save_incomplete!)

      get edit_bulk_upload_path(bulk_upload)

      expect(response).to be_successful
      expect(response.body.index("Unvollständige Meldungen (1)")).to be < response.body.index("Vollständige Meldungen (1)")
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

    it "assigns a blueprint notices" do
      blueprint = Fabricate(:blueprint, user:)
      params = {
        blueprint_id: blueprint.id,
        bulk_upload: {
          photos: [bulk_upload.photos.first.id],
        },
      }
      expect do
        expect do
          patch bulk_upload_path(bulk_upload), params:
        end.to change { user.notices.count }.by(1)
      end.to have_enqueued_job(AnalyzerJob)

      expect(user.notices.last.blueprint).to eq(blueprint)
      expect(response).to be_a_redirect
    end

    it "updates the resource with photos" do
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

  context "POST :zip" do
    it "imports images from zip" do
      params = {
        bulk_upload: {
          zip:,
        },
      }
      expect do
        expect do
          post zip_bulk_uploads_path, params:
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
