# frozen_string_literal: true

class StyleguideController < ApplicationController
  def photo
    key = "#{params[:key]}.#{params[:extension]}"
    photo = ActiveStorage::Blob.find_by_key(key)
    redirect_to rails_storage_redirect_url(
                  photo.variant(
                    resize: "#{params[:width]}x#{params[:height]}",
                    quality: params[:quality],
                    auto_orient: true
                  )
                )
  end
end
