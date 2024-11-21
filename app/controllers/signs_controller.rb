# frozen_string_literal: true

class SignsController < ApplicationController
  def index
    respond_to do |format|
      format.html { @signs = search_scope }
      format.json { render json: Sign.as_api_response(:public_beta) }
    end
  end

  def show
    @since = (params[:since] || 4).to_i
    @display = %w[cluster heat multi].delete(params[:display]) || "cluster"

    @signs = Sign.by_param(params[:id]).ordered
    @sign = @signs.first!
    @notices = @sign.notices.shared.since(@since.weeks.ago)
  end

  def show
    @sign = Sign.from_param(params[:id])
    respond_to do |format|
      format.html
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
