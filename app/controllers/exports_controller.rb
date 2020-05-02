class ExportsController < ApplicationController
  def index
    @exports = Export.order(params[:order] || 'created_at DESC').page(params[:page])
  end
end
