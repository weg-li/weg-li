# frozen_string_literal: true

require "spec_helper"

describe "admin/notices", type: :request do
  let(:admin) { Fabricate(:user, access: :admin) }

  before do
    login(admin)
  end

  context "GET: index" do
    it "index works" do
      Fabricate(:notice, user: admin)
      get admin_notices_path

      expect(response).to be_ok
    end
  end

  context "GET: show" do
    it "show works" do
      notice = Fabricate(:notice, user: admin)
      get admin_notice_path(notice)

      expect(response).to be_ok
    end

    it "show works with ID" do
      notice = Fabricate(:notice, user: admin)
      get admin_notice_path(notice.id)

      expect(response).to be_ok
    end
  end
end
