require 'spec_helper'

describe 'session', type: :request do

  context "with login" do
    before do
      @user = login
    end

    context "POST :email_signup" do
      it "renders the page" do
        expect {
          post email_signup_path, params: {email: @user.email}

          expect(response).to be_a_redirect
        }.to have_enqueued_mail(UserMailer, :login_link)

      end
    end
  end

  context "without login" do
    context "POST :email_signup" do
      it "renders the page" do
        expect {
          post email_signup_path, params: {email: 'any@email.address'}

          expect(response).to be_a_redirect
        }.to have_enqueued_mail(UserMailer, :signup_link)

      end
    end
  end
end
