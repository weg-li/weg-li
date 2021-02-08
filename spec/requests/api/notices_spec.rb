require 'swagger_helper'

RSpec.describe 'api/notices', type: :request do

  let(:current_user) { Fabricate.create(:user) }
  let(:current_notice) { Fabricate.create(:notice, user: current_user) }
  let(:id) { current_notice.token }
  let('X-API-KEY') { current_user.api_token }


  path '/api/notices/{id}/mail' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    patch('mail notice') do
      security [ ApiKeyAuth: 'X-API-KEY' ]
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/notices' do
    get('list notices') do
      security [ ApiKeyAuth: 'X-API-KEY' ]

      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    post('create notice') do
      security [ ApiKeyAuth: 'X-API-KEY' ]
      consumes 'application/json'
      parameter name: :notice, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        },
        required: [ 'title', 'content' ]
      }
      let(:notice) { current_notice.attributes }

      response(201, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/notices/new' do
    get('new notice') do
      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/notices/{id}/edit' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('edit notice') do
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/notices/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'
    parameter name: :blog, in: :body, schema: {
      type: :object,
      properties: {
        title: { type: :string },
        content: { type: :string }
      },
      required: [ 'title', 'content' ]
    }

    get('show notice') do
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    patch('update notice') do
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end

    put('update notice') do
      produces 'application/json'
      parameter name: :notice, in: :body, schema: {
        type: :object,
        properties: {
          token: { type: :string },
        },
      }
      security [ ApiKeyAuth: 'X-API-KEY' ]

      response(200, 'successful') do
        let(:notice) { current_notice.attributes }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end

    delete('delete notice') do
      security [ ApiKeyAuth: 'X-API-KEY' ]

      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: response.body
            }
          }
        end

        run_test!
      end
    end
  end
end
