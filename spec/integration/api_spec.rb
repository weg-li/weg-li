require 'swagger_helper'

describe 'Notices API' do

  let(:user) { Fabricate.create(:user) }
  let(:notice) { Fabricate.create(:notice, user: user) }
  let('X-API-KEY') { user.api_token }

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

  path '/api/notices/' do
    get 'Retrieves a list of notices' do
      tags 'Notices'
      produces 'application/json'
      security [ ApiKeyAuth: 'X-API-KEY' ]

      response '200', 'notice found' do
        schema type: :object,
          properties: {}

        run_test!
      end
    end
  end

  path '/api/notices/{id}' do
    get 'Retrieves a notice' do
      tags 'Notices'
      produces 'application/json'
      parameter name: :id, in: :path, schema: { type: :string }
      security [ ApiKeyAuth: 'X-API-KEY' ]

      response '200', 'notice found' do
        schema type: :object,
          properties: {
            token: { type: :string, example: '21f96e417ca2050a075d2cb056a4f670'},
            status: { type: :string },
            street: { type: :string, },
            zip: { type: :string, },
            city: { type: :string, },
            latitude: { type: :number, },
            longitude: { type: :number, },
            registration: { type: :string, },
            color: { type: :string, },
            brand: { type: :string, },
            charge: { type: :string, },
            date: { type: :string, format: :"date-time" },
            severity: { type: :string, },
            vehicle_empty: { type: :boolean, },
            hazard_lights: { type: :boolean, },
            expired_tuv: { type: :boolean, },
            expired_eco: { type: :boolean, },
            duration: { type: :integer, },
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
