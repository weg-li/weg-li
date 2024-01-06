# frozen_string_literal: true

class BrandsController < ApplicationController
  def index
    respond_to do |format|
      format.html { @brands = search_scope }
    end
  end

  def show
    @since = (params[:since] || 4).to_i
    @display = %w[cluster heat multi].delete(params[:display]) || "cluster"

    @brand = Brand.from_param(params[:id])
    @notices = @brand.notices.shared.since(@since.weeks.ago)
  end

  def new
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(brand_params.merge(status: :proposed))
    if @brand.save
      notify("new brand proposed: #{edit_admin_brand_url(@brand)}#{" by #{current_user.email}" if signed_in?}")

      redirect_to(brands_path, notice: "Marke wurde erfasst und wartet nun auf Freischaltung")
    else
      render(:new)
    end
  end

  def edit
    @brand = Brand.active.from_param(params[:id])
  end

  def update
    brand = Brand.active.from_param(params[:id])
    brand.assign_attributes(brand_params)
    changes = brand.changes

    if changes.present?
      message = changes.map { |key, (from, to)| "#{key} changed from #{from} to #{to}" }.join(", ")
      notify("brand changes proposed: #{message} #{edit_admin_brand_url(brand)}#{" by #{current_user.email}" if signed_in?}",)
    end

    redirect_to(brands_path, notice: "Änderungen wurden erfasst und warten nun auf Freischaltung")
  end

  private

  def search_scope
    brands = Brand.order(params[:order] || "name ASC").page(params[:page])
    if params[:term].present?
      brands = brands.where("name ILIKE :term", term: "%#{params[:term]}%")
    end
    if params[:kind].present?
      brands = brands.where("kind = ?", Brand.kinds[params[:kind]])
    end
    brands
  end

  def brand_params
    params[:brand][:models] = params[:brand][:models].split(/;|,|\s/).reject(&:blank?)
    params.require(:brand).permit(
      :name,
      :kind,
      models: [],
    )
  end
end
