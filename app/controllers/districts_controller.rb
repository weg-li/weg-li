class DistrictsController < ApplicationController
  def index
    respond_to do |format|
      format.html { @districts = search_scope }
      format.json { render json: District.all.as_api_response(:public_beta) }
    end
  end

  def show
    @district = District.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @district.as_api_response(:public_beta) }
    end
  end

  def wegeheld
    district = District.find_by!(zip: params[:id])

    respond_to do |format|
      format.json { render json: district.as_api_response(:wegeheld) }
    end
  end

  private

  def search_scope
    scope = District.order(params[:order] || 'zip ASC').page(params[:page])
    scope = scope.where('zip ILIKE :term OR name ILIKE :term', term: "%#{params[:term]}%") if params[:term]
    scope
  end
end
