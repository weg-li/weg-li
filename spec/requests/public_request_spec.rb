# frozen_string_literal: true

require 'spec_helper'

describe 'public', type: :request do
  before do
    @notice = Fabricate(:notice)
    @user = @notice.user
  end

  context 'GET :charge' do
    it 'shows the charge' do
      get public_charge_path(token: @notice.to_param)

      expect(response).to be_successful
      assert_select('.panel-heading', "Anzeige: #{@notice.registration} #{@notice.charge}")
    end
  end

  context 'GET :profile' do
    it 'shows the public-profile' do
      get public_profile_path(token: @user.to_param)

      expect(response).to be_successful
      assert_select('h3', "#{@user.nickname} in #{@user.city}")
    end
  end

  context 'GET :winowig' do
    it 'renders a charge in winowig format' do
      get public_winowig_path(user_token: @user.to_param, notice_token: @notice.to_param, format: :xml)

      expect(response).to be_successful
      assert_select('Fall')
    end

    it 'renders 404 with bad data' do
      get public_winowig_path(user_token: @user.to_param, notice_token: 'some token', format: :xml)

      expect(response).to be_not_found
    end

    it 'renders 404 with exired data' do
      @notice.update!(date: 2.months.ago)
      get public_winowig_path(user_token: @user.to_param, notice_token: @notice.to_param, format: :xml)

      expect(response).to be_not_found
    end
  end
end
