# frozen_string_literal: true

class SignsController < ApplicationController
  def index
    respond_to do |format|
      format.html { @signs = search_scope }
      format.csv do
        csv_data = CSV.generate(force_quotes: true) do |csv|
          csv << %w[Nummber Beschreibung]
          Sign.ordered.pluck(:number, :description).each { |sign| csv << sign }
        end
        send_data(csv_data, type: "text/csv; charset=UTF-8; header=present", disposition: "attachment; filename=signs-#{Time.now.to_i}.csv")
      end
    end
  end

  def show
    @sign = Sign.from_param(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @sign.as_api_response(:public_beta) }
      format.png do
        send_data @sign.file.read, type: "image/png", disposition: "inline"
      end
    end
  end

  private

  def search_scope
    signs = Sign.order(params[:order] || "number ASC").page(params[:page])
    if params[:term].present?
      signs = signs.where("number ILIKE :term OR description ILIKE :term", term: "%#{params[:term]}%")
    end
    signs
  end
end
