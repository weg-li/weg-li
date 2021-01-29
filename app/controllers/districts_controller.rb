class DistrictsController < ApplicationController
  include Slack::Slackable

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
    @since = (params[:since] || 4).to_i
    @display = %w(cluster multi).delete(params[:display]) || 'cluster'
    @district = District.active.from_param(params[:id])
    @notices = @district.notices.since(@since.weeks.ago).shared

    respond_to do |format|
      format.html
      format.json { render json: @district.as_api_response(:public_beta) }
    end
  end

  def edit
    @district = District.active.from_param(params[:id])
  end

  def update
    district = District.active.from_param(params[:id])
    district.assign_attributes(district_params)
    changes = district.changes

    if changes.present?
      message = changes.map {|key, (from, to)| "#{key} changed from #{from} to #{to}" }.join(', ')
      notify("district changes proposed: #{message} #{admin_district_url(district)}")
    end

    redirect_to(districts_path, notice: 'Änderungen wurden erfasst und warten nun auf Freischaltung')
  end

  def new
    @district = District.new
  end

  def create
    @district = District.new(district_params.merge(status: :proposed))
    if @district.save
      notify("new district proposed: #{admin_district_url(@district)}")

      redirect_to(districts_path, notice: 'Bezirk wurde erfasst und wartet nun auf Freischaltung')
    else
      render(:new)
    end
  end

  def wegeheld
    district = District.active.from_param(params[:id])

    respond_to do |format|
      format.json { render json: district.as_api_response(:wegeheld) }
    end
  end

  private

  def district_params
    params[:district][:prefix] = params[:district][:prefix].split(/;|,|\s/).reject(&:blank?)
    params.require(:district).permit(:name, :email, :zip, :state, :osm_id, prefix: [])
  end

  def search_scope
    scope = District.active.order(params[:order] || 'zip ASC').page(params[:page])
    scope = scope.where('zip ILIKE :term OR name ILIKE :term OR email ILIKE :term', term: "%#{params[:term]}%") if params[:term]
    scope
  end
end
