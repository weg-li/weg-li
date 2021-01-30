require 'csv'

class ChargesController < ApplicationController
  def index
    @charges = Charge.active.order(params[:order] || 'tbnr ASC').page(params[:page])
    @charges = @charges.where('tbnr ILIKE :term OR description ILIKE :term', term: "%#{params[:term]}%") if params[:term]
  end

  def show
    @since = (params[:since] || 4).to_i
    @display = %w(cluster multi).delete(params[:display]) || 'cluster'

    @charge = Charge.active.from_param(params[:id])
    @notices = Notice.since(@since.weeks.ago).shared.where(charge: Charge.plain_charges_tbnr(@charge.tbnr))
  end

  def list
    respond_to do |format|
      format.csv do
        csv_data = CSV.generate(force_quotes: true) do |csv|
          csv << ["Nr","TBNR","Tatbestand"]
          Charge::CHARGES.each_with_index { |(tbnr, charge), index| csv << [index + 1, tbnr, charge] }
        end
        send_data csv_data, type: 'text/csv; charset=UTF-8; header=present', disposition: "attachment; filename=districts-#{Time.now.to_i}.csv"
      end
    end
  end
end
