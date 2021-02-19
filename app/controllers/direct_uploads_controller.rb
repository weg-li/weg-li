class DirectUploadsController < ApplicationController
  def analyze
    signed_id = params.dig(:blob, :signed_id)

    blob = ActiveStorage::Blob.find_signed!(signed_id)

    ThumbnailerJob.perform_later(blob)

    render json: blob
  end
end
