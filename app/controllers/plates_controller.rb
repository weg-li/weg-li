# frozen_string_literal: true

class PlatesController < ApplicationController
  def index
    respond_to do |format|
      format.html { @plates = search_scope }
      format.csv do
        csv_data = CSV.generate(force_quotes: true) do |csv|
          csv << %w[Name Ortskennzeichen]
          Plate.ordered.pluck(:name, :prefix).each { |plate| csv << plate }
        end
        send_data(csv_data, type: "text/csv; charset=UTF-8; header=present", disposition: "attachment; filename=plate-#{Time.now.to_i}.csv")
      end
    end
  end

  def show
    @plate = Plate.from_param(params[:id])
    respond_to do |format|
      format.html do
        @districts = District.where(zip: @plate.zips).pluck(:name, :zip).group_by { |name, zip| name }
        render :show
      end
      format.json { render json: @plate.as_api_response(:public_beta) }
    end
  end

  private

  def search_scope
    plate = Plate.order(params[:order] || "name ASC").page(params[:page])
    if params[:term].present?
      plate = plate.search(params[:term])
    end
    plate
  end
end
