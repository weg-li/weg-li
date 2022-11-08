# frozen_string_literal: true

require 'spec_helper'

describe 'api/uploads', type: :request do
  before do
    @user = Fabricate(:user)
    @headers = { 'X-API-KEY' => @user.api_token }
  end

  context 'index' do
    it 'create works' do
      params = {
        upload: {
          filename: 'text.jpg',
          byte_size: 1.megabyte,
          checksum: 'AABBCC',
          content_type: 'image/jpeg',
          metadata: { content_type: 'image/jpeg' },
        },
      }

      post(api_uploads_path, params:, headers: @headers)

      expect(response).to be_created
      expect(JSON.parse(response.body)['direct_upload'].keys).to eql(%w[url headers])
    end
  end
end
