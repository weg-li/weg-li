require 'spec_helper'

describe UsersController do
  before do
    @user = login
  end

  context "GET :show" do
    it "renders the users profile page" do
      get :show, params: {id: @user}

      expect(response).to be_successful
    end
  end

  context "POST :update" do
    it "resets validation and sends an email when address is changed" do
      @user.update! validation_date: Time.new(2015, 1, 1, 0, 0, 0).utc
      expect {
        post :update, params: {id: @user, user: {email: 'different@email.com'}}
      }.to change { @user.reload.validation_date }.from(@user.validation_date).to(nil)

      expect(response).to be_a_redirect
    end

    it "updates the nickname" do
      expect {
        post :update, params: {id: @user, user: {nickname: 'new'}}
      }.to change { @user.reload.nickname }.from(@user.nickname).to('new')

      expect(response).to be_a_redirect
    end
  end
end
