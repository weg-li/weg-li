class ExportsController < ApplicationController
  def index
    @exports = Export.order(params[:order] || 'created_at ASC').page(params[:page])
  end
end
