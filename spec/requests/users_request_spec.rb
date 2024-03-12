# frozen_string_literal: true

require "spec_helper"

describe "users", type: :request do
  before do
    @user = login
  end

  context "GET :edit" do
    it "renders the page" do
      get user_path

      expect(response).to be_successful
      assert_select(".panel-heading", "Infos zum Account")
    end
  end

  context "GET :edit" do
    it "renders the page" do
      get edit_user_path

      expect(response).to be_successful
      assert_select(".panel-heading", "Persönliche Daten 👤")
    end
  end

  context "PATCH :update" do
    it "resets validation and sends an email when address is changed" do
      @user.update! validation_date: Time.new(2015, 1, 1, 0, 0, 0).utc
      expect do
        patch user_path(@user), params: { user: { email: "different@email.com" } }
      end.to change { @user.reload.validation_date }.from(@user.validation_date).to(nil)

      expect(response).to be_a_redirect
    end

    it "renders an error when invalid" do
      expect do
        patch user_path(@user), params: { user: { name: "invalid" } }
      end.not_to(change { @user.reload.name })

      expect(response).to be_a_redirect
    end

    it "updates the nickname" do
      expect do
        patch user_path(@user), params: { user: { nickname: "new" } }
      end.to change { @user.reload.nickname }.from(@user.nickname).to("new")

      expect(response).to be_a_redirect
    end
  end
end
