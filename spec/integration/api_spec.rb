require 'swagger_helper'

describe 'Notices API' do

  let(:notice) { Fabricate.create(:notice) }

  # path '/api/notices' do
  #
  #   post 'Creates a notice' do
  #     tags 'Notices'
  #     consumes 'application/json', 'application/xml'
  #     parameter name: :notice, in: :body, schema: {
  #       type: :object,
  #       properties: {
  #         name: { type: :string },
  #         photo_url: { type: :string },
  #         status: { type: :string }
  #       },
  #       required: [ 'name', 'status' ]
  #     }
  #
  #     response '201', 'notice created' do
  #       let(:notice) { { name: 'Dodo', status: 'available' } }
  #       run_test!
  #     end
  #
  #     response '422', 'invalid request' do
  #       let(:notice) { { name: 'foo' } }
  #       run_test!
  #     end
  #   end
  # end

  path '/api/notices/{id}' do

    let('X-API-KEY') { notice.user.api_token }

    get 'Retrieves a notice' do
      tags 'Notices'
      produces 'application/json'
      parameter name: :id, in: :path, schema: { type: :string }
      security [ ApiKeyAuth: 'X-API-KEY' ]

      response '200', 'notice found' do
        schema type: :object,
          properties: {
            token: { type: :string, },
            status: { type: :string },
            # registration: { type: :string, },
            # charge: { type: :string, },
            # street: { type: :string, },
            # zip: { type: :string, },
            # city: { type: :string, },
            # date: { type: :time, },
            # duration: { type: :integer, },
            # severity: { type: :integer, },
            # location: { type: :string },
            # photo_url: { type: :string },
          },
          required: [ 'token', 'status' ]

        let(:id) { notice.to_param }
        run_test!
      end

      response '404', 'notice not found' do
        let(:id) { 'invalid' }

        run_test!
      end
    end
  end
end
