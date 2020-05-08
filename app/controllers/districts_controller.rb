class DistrictsController < ApplicationController
  def index
    respond_to do |format|
      format.html { @districts = search_scope }
      format.json { render json: District.active.as_api_response(:public_beta) }
      format.csv do
        csv_data = CSV.generate(force_quotes: true) do |csv|
          csv << ["plz","name","email"]
          District.in_batches do |relation|
            relation.each { |district| csv << [district.zip, district.name, district.email] }
          end
        end
        send_data csv_data, type: 'text/csv; charset=UTF-8; header=present', disposition: "attachment; filename=districts-#{Time.now.to_i}.csv"
      end
    end
  end

  def show
    @district = District.active.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @district.as_api_response(:public_beta) }
    end
  end

  def wegeheld
    district = District.active.find_by!(zip: params[:id])

    respond_to do |format|
      format.json { render json: district.as_api_response(:wegeheld) }
    end
  end

  private

  def search_scope
    scope = District.active.order(params[:order] || 'zip ASC').page(params[:page])
    scope = scope.where('zip ILIKE :term OR name ILIKE :term', term: "%#{params[:term]}%") if params[:term]
    scope
  end
end
