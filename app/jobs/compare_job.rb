class CompareJob < ApplicationJob
  def perform(notice)
    Rails.logger.info("comparing #{notice.id}")

    image_upload_response = analyze_api_client.analyze_image_upload_get(quantity: notice.photos.size)
    notice.photos.each_with_index do |photo, i|
      url = image_upload_response.google_cloud_urls[i]

      photo.service.download_file(photo.key) do |file|
        header = { 'Content-Type' => 'image/jpeg' }
        res = HTTPClient.new.put(url, header: header, body: file)
        raise res.body unless res.ok?
      end

      data_set = notice.data_sets.google_vision.find_by(keyable: photo)
      notify("for notice #{notice.id} google found #{data_set.registrations} #{data_set.brands} #{data_set.colors}") if data_set
    end

    analyze_image_response =  analyze_api_client.analyze_image_image_token_get(image_upload_response.token)
    notify("for notice #{notice.id} the project found #{analyze_image_response.suggestions}")
  end

  private

  def analyze_api_client
    @analyze_api_client ||= OpenapiClient::AnalyzeApi.new
  end
end
