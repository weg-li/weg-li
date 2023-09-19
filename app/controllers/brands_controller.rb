# frozen_string_literal: true

class BrandsController < ApplicationController
  def index
    respond_to do |format|
      format.html { @charges = search_scope }
    end
  end

  def show
    @since = (params[:since] || 4).to_i
    @display = %w[cluster heat multi].delete(params[:display]) || "cluster"

    @brand = Brand.from_param(params[:id])
    @notices = @brand.notices.shared.since(@since.weeks.ago)
  end

  private

  def search_scope
    brands = Brand.order(params[:order] || "name ASC").page(params[:page])
    if params[:term].present?
      brands = brands.where("name ILIKE :term", term: "%#{params[:term]}%")
    end
    if params[:kind].present?
      brands = brands.where("kind = ?", params[:kind].to_i)
    end
    brands
  end
end
