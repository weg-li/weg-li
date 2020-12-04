class ExportsController < ApplicationController
  def index
    @exports = Export.for_public.order(params[:order] || 'created_at DESC').page(params[:page])
  end
end
