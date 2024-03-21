# frozen_string_literal: true

require "rails_helper"

describe "exports", type: :request do
  let(:user) { Fabricate(:user) }

  before do
    login(user)
  end

  describe "GET user/exports" do
    it "works!" do
      get user_exports_path

      expect(response).to be_ok
    end
  end

  describe "POST user/exports" do
    let(:params) do
      { export: { export_type: "notices", file_extension: "csv" } }
    end

    it "works!" do
      expect do
        expect do
          post(user_exports_path, params:)
        end.to change { user.exports.count }.by(1)
      end.to have_enqueued_job(UserExportJob)

      expect(response).to be_redirect
    end
  end

  describe "DEETE user/exports" do
    it "works!" do
      export = Fabricate(:export, user:)
      expect do
        delete(user_export_path(export))

        expect(response).to be_redirect
      end.to change { user.exports.count }.by(-1)
    end
  end
end
