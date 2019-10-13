class DistrictsController < ApplicationController
  def index
    @districts = search_scope
  end

  def show
    @district = District.find(params[:id])
  end

  private

  def search_scope
    scope = District.order(params[:order] || 'zip ASC').page(params[:page])
    scope = scope.where('zip ILIKE :term OR name ILIKE :term', term: "%#{params[:term]}%") if params[:term]
    scope
  end
end
