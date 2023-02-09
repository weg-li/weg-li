# frozen_string_literal: true

require 'spec_helper'

describe 'session', type: :request do
  context 'with login' do
    before do
      @user = login
    end

    context 'POST :email_signup' do
      it 'renders the page' do
        expect do
          post email_signup_path, params: { email: @user.email }

          expect(response).to be_a_redirect
        end.to have_enqueued_mail(UserMailer, :login_link)
      end
    end
  end

  context "with authorization" do
    before do
      @user = Fabricate(:authorization).user
      login(@user)
    end

    describe "DELETE :disconnect" do
      it 'deletes an authorization' do
        expect do
          provider = @user.authorizations.first.provider
          delete "/auth/#{provider}"
  
          expect(response).to be_a_redirect
        end.to change { @user.authorizations.count }.by(-1)
     end
    end
  end

  context 'without login' do
    context 'POST :email_signup' do
      it 'renders the page' do
        expect do
          post email_signup_path, params: { email: 'any@email.address' }

          expect(response).to be_a_redirect
        end.to have_enqueued_mail(UserMailer, :signup_link)
      end
    end
  end
end
