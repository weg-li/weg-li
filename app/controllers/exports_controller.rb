# frozen_string_literal: true

class ExportsController < ApplicationController
  def index
    @exports =
      Export
        .for_public
        .order(params[:order] || "created_at DESC")
        .with_attached_archive
        .page(params[:page])
  end
end
