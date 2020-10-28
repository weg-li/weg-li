class ChargesController < ApplicationController
  def index
    @charges = Charge.active.order(params[:order] || 'tbnr ASC').page(params[:page])
    @charges = @charges.where('tbnr ILIKE :term OR description ILIKE :term', term: "%#{params[:term]}%") if params[:term]
  end

  def show
    @charge = Charge.active.from_param(params[:id])
  end
end
