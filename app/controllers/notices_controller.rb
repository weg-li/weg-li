class NoticesController < ApplicationController
  before_action :authenticate!
  before_action :authenticate_community_user!, only: [:colors]
  before_action :authenticate_admin_user!, only: [:inspect]
  before_action :validate!, except: [:index]

  def index
    @table_params = {
      search: {},
      filter: {},
      order: {},
    }

    @notices = current_user.notices.page(params[:page])

    if search = params[:search]
      @table_params[:search] = search.to_unsafe_hash
      @notices = @notices.search(search[:term]) if search[:term].present?
    end
    if filter = params[:filter]
      @table_params[:filter] = filter.to_unsafe_hash
      @notices = @notices.where(status: filter[:status]) if filter[:status].present?
    end
    if order = params[:order]
      @table_params[:order] = order.to_unsafe_hash
      if order[:column].present? && order[:value].present?
        @notices = @notices.reorder(order[:column] => order[:value])
      end
    end
  end

  def suggest
    notices = current_user.notices.since(2.month.ago).search(params[:term]).order(:registration).limit(25)

    results = notices.pluck(:registration, :brand, :color).uniq.map do |registration, brand, color|
      {
        id: registration,
        text: registration,
        brand: brand,
        color: color,
      }
    end
    results += [{ id: params[:term], text: params[:term] }]
    if access?(:admin)
      notice = current_user.notices.from_param(params[:id])
      results += notice.possible_registrations.map { |registration| { id: registration, text: registration } }
    end

    render json: { results: results }.to_json
  end

  def map
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    @district = params[:district] || current_user.city

    @notices = current_user.notices.since(@since.days.ago).joins(:district).where(districts: {name: @district})
    @default_district = District.from_zip(current_user.zip) || District.active.first
  end

  def stats
    @weeks = 12
    @notice_counts = Notice.count_over(current_user.notices.shared, weeks: @weeks)
    @notice_sums = Notice.sum_over(current_user.notices.shared, weeks: @weeks)
    @photo_counts = Notice.count_over(ActiveStorage::Attachment.where(record_type: 'Notice', record_id: current_user.notices.shared.pluck(:id), name: 'photos'), weeks: @weeks)
    @photo_sums = Notice.sum_over(ActiveStorage::Attachment.where(record_type: 'Notice', record_id: current_user.notices.shared.pluck(:id), name: 'photos'), weeks: @weeks)
  end

  def show
    @notice = current_user.notices.from_param(params[:id])
  end

  def new
    @notice = current_user.notices.build(date: Time.zone.today)
  end

  def create
    notice = current_user.notices.build(notice_upload_params)
    notice.analyze!

    redirect_to edit_notice_path(notice), notice: 'Eine Meldung mit Beweisfotos wurde erfasst und die Analyse gestartet'
  end

  def edit
    @notice = current_user.notices.from_param(params[:id])
  end

  def update
    @notice = current_user.notices.from_param(params[:id])

    if @notice.update(notice_update_params)
      redirect_to [:share, @notice], notice: 'Meldung wurde gespeichert'
    else
      render :edit
    end
  end

  def upload
    notice = current_user.notices.from_param(params[:id])
    notice.assign_attributes(notice_upload_params)
    notice.save_incomplete!

    redirect_to [:edit, notice], notice: 'Beweisfotos wurden hochgeladen'
  end

  def share
    @notice = current_user.notices.complete.from_param(params[:id])

    @mail = NoticeMailer.charge(@notice)
  end

  def forward
    notice = current_user.notices.from_param(params[:id])
    token = Token.generate(current_user.token)
    NoticeMailer.forward(notice, token).deliver_later

    redirect_to(notices_path, notice: "Eine E-Mail mit einem geheimen Link zum Übertragen ist zu Dir unterwegs.")
  end

  def retrieve
    token = Token.decode(params[:token])
    user = User.from_param(token['iss'])
    notice = user.notices.open.from_param(params[:id])
    notice.update! user: current_user

    redirect_to(notice, notice: "Meldung wurde in Deinen Account übernommen.")
  rescue JWT::ExpiredSignature
    redirect_to(notices_path, alert: "Der Link ist leider schon abgelaufen!")
  end

  def status
    @notice = current_user.notices.from_param(params[:id])
    @notice.update!(status: :shared)

    redirect_to(notices_path, notice: "Deine Anzeige wurde als 'gemeldet' markiert.")
  end

  def mail
    notice = current_user.notices.complete.from_param(params[:id])

    to = params[:send_to] == 'all' ? notice.district.all_emails : notice.district.all_emails.find {|email| email == params[:send_to]}
    to ||= notice.district.email

    NoticeMailer.charge(notice, to, params[:send_via_pdf]).deliver_later

    notice.update!(status: :shared)

    redirect_to(notices_path, notice: "Deine Anzeige wird per E-Mail an #{Array(to).join(', ')} versendet und als 'gemeldet' markiert.")
  end

  def duplicate
    notice = current_user.notices.from_param(params[:id])
    notice = notice.duplicate!

    redirect_to edit_notice_path(notice), notice: 'Die Meldung wurde dupliziert'
  end

  def enable
    notice = current_user.notices.from_param(params[:id])
    notice.status = :open
    notice.save_incomplete!

    redirect_to notices_path, notice: t('notices.enabled')
  end

  def disable
    notice = current_user.notices.from_param(params[:id])
    notice.status = :disabled
    notice.save_incomplete!

    redirect_to notices_path, notice: t('notices.disabled')
  end

  def inspect
    @notice = current_user.notices.from_param(params[:id])
    @photo = @notice.photos.find(params[:photo_id])
    @exif = @photo.service.download_file(@photo.key) { |file| EXIFAnalyzer.new.metadata(file, debug: true) }
    @result = Annotator.new.annotate_object(@photo.key)
  end

  def colors
    @notice = current_user.notices.from_param(params[:id])
    @photo = @notice.photos.find(params[:photo_id])
  end

  def destroy
    notice = current_user.notices.from_param(params[:id])
    notice.destroy!

    redirect_to notices_path, notice: t('notices.destroyed')
  end

  def pdf
    notice = current_user.notices.complete.from_param(params[:id])
    data = PDFGenerator.new.generate(notice)

    send_data data, filename: notice.file_name
  end

  def bulk
    action = params[:bulk_action]
    notices = current_user.notices.where(id: params[:selected])

    case action
    when 'share'
      notices = notices.open.complete
      if notices.present?
        notices.each do |notice|
          NoticeMailer.charge(notice).deliver_later
          notice.update! status: :shared
        end
        flash[:notice] = 'Die noch offenen, vollständigen Meldungen werden im Hintergrund per E-Mail gemeldet'
      else
        flash[:notice] = 'Keine vollständigen Meldungen zum melden gefunden!'
      end
    when 'pdf'
      notices = notices.complete
      if notices.present?
         notices.pluck(:id).each_slice(5) do |notice_ids|
           UserMailer.pdf(current_user, notice_ids).deliver_later
         end
        flash[:notice] = 'Die vollständigen Meldungen wurden als PDF generiert und per E-Mail zugeschickt'
      else
        flash[:notice] = 'Keine vollständigen Meldungen zum generieren gefunden!'
      end
    when 'status'
      notices = notices.open.complete
      if notices.present?
        notices.update(status: :shared)
        flash[:notice] = 'Die offenen, vollständigen Meldungen wurden als "gemeldet" markiert'
      else
        flash[:notice] = 'Keine offenen, vollständigen Meldungen zum markieren gefunden!'
      end
    when 'destroy'
      if notices.present?
        notices.destroy_all
        flash[:notice] = 'Die Meldungen wurden gelöscht'
      else
        flash[:notice] = 'Keine Meldungen zum löschen gefunden!'
      end
    end

    redirect_to notices_path
  end

  def analyze
    notice = current_user.notices.from_param(params[:id])

    if notice.analyzing?
      redirect_back fallback_location: notice_path(notice), notice: 'Analyse läuft bereits'
    else
      notice.analyze!

      redirect_back fallback_location: notice_path(notice), notice: 'Analyse gestartet, es kann einen Augenblick dauern'
    end
  end

  def purge
    notice = current_user.notices.from_param(params[:id])
    notice.photos.find(params[:photo_id]).purge_later

    redirect_back fallback_location: notice_path(notice), notice: 'Foto gelöscht'
  end

  private

  def notice_update_params
    params.require(:notice).permit(:charge, :date, :date_date, :date_time, :registration, :brand, :color, :street, :zip, :city, :latitude, :longitude, :note, :duration, :severity, :vehicle_empty, :hazard_lights, :expired_tuv, :expired_eco)
  end

  def notice_upload_params
    params.require(:notice).permit(:charge, :flags, :severity, :duration, :note, photos: [])
  end
end
