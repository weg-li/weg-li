class YoloAnalyzerJob < ApplicationJob
  retry_on ActiveStorage::FileNotFoundError, attempts: 15, wait: :exponentially_longer

  def perform(notice)
    handle_car_ml(notice)
  end

  private

  def handle_car_ml(notice)
    api = create_api

    photos = notice.photos.first(2)
    image_upload_response = api.analyze_image_upload_get(quantity: photos.size)
    photos.each_with_index do |photo, i|
      url = image_upload_response.google_cloud_urls[i]

      photo.service.download_file(photo.key) do |file|
        header = { 'Content-Type' => 'image/jpeg' }
        res = HTTPClient.new.put(url, header: header, body: file)
        notify("could not upload photo #{photo.id} for notice: https://www.weg.li/admin/notices/#{notice.token}") unless res.ok?
      end
    end

    response = api.analyze_image_image_token_get(image_upload_response.token)
    notice.data_sets.create!(data: response.to_json, kind: :car_ml, keyable: notice)
  end

  def create_api
    config = OpenapiClient::Configuration.new
    config.host = 'https://europe-west3-wegli-296209.cloudfunctions.net/'
    config.base_path = 'api'
  	config.debugging = true

    client = OpenapiClient::AnalyzeApi.new
    client.api_client.config = config
    client
  end
end
