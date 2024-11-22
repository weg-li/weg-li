# frozen_string_literal: true

class ChargesController < ApplicationController
  def index
    respond_to do |format|
      format.html { @charges = search_scope }
      format.json { render json: Charge.active.as_api_response(:public_beta) }
    end
  end

  def show
    @since = (params[:since] || 4).to_i
    @display = %w[cluster heat multi].delete(params[:display]) || "cluster"

    @charges = Charge.by_param(params[:id]).ordered
    @charge = @charges.first!
    @notices = @charge.notices.shared.since(@since.weeks.ago)
  end

  def list
    respond_to do |format|
      format.csv do
        csv_data = CSV.generate(force_quotes: true) do |csv|
          csv << %w[Nr TBNR Tatbestand]
          Charge.tbnrs_with_description.each_with_index { |(tbnr, charge), index| csv << [index + 1, tbnr, charge] }
        end
        send_data(csv_data, type: "text/csv; charset=UTF-8; header=present", disposition: "attachment; filename=districts-#{Time.now.to_i}.csv")
      end
    end
  end

  private

  def search_scope
    charges = Charge.active.order(params[:order] || "tbnr ASC").page(params[:page])
    if params[:term].present?
      charges = charges.where("tbnr ILIKE :term OR description ILIKE :term", term: "%#{params[:term]}%")
    end
    if params[:classification].present?
      charges = charges.where("classification = ?", params[:classification].to_i)
    end
    charges
  end
end
