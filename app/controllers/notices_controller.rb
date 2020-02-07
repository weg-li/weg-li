class NoticesController < ApplicationController
  before_action :authenticate!
  before_action :authenticate_community_user!, only: [:prepare, :polish]
  before_action :authenticate_admin_user!, only: [:inspect, :colors]
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

    render json: { results: results }.to_json
  end

  def map
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    @district = params[:district] || current_user.city

    @notices = current_user.notices.since(@since.days.ago).joins(:district).where(districts: {name: @district})
    @default_district = District.from_zip(current_user.zip) || District.first
  end

  def stats
    @months = 6
    @notice_counts = Notice.count_by_month(current_user.notices.shared, months: @months)
    @notice_sums = Notice.sum_by_month(current_user.notices.shared, months: @months)
    @photo_counts = Notice.count_by_month(ActiveStorage::Attachment.where(record_type: 'Notice', record_id: current_user.notices.shared.pluck(:id), name: 'photos'), months: @months)
    @photo_sums = Notice.sum_by_month(ActiveStorage::Attachment.where(record_type: 'Notice', record_id: current_user.notices.shared.pluck(:id), name: 'photos'), months: @months)
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

  def import
    tweet = Twttr.client.status(notice_import_params[:tweet_url], tweet_mode: :extended)
    nickname = tweet.user.screen_name
    if User.where(nickname: nickname).any?
      redirect_to new_notice_path, notice: "Der Nutzer #{nickname} besteht bereits im System"
      return
    end

    import_user = User.new(nickname: nickname, name: tweet.user.name, city: tweet.user.location, access: :ghost)
    import_user.save(validate: false)

    notice = import_user.notices.build(notice_import_params)
    notice.date = tweet.created_at
    notice.note = tweet.attrs[:full_text]
    coordinates = (tweet.geo || tweet.coordinates)&.coordinates
    if coordinates.present?
      notice.longitude = coordinates.first
      notice.latitude = coordinates.last
    end
    tweet.media.each do |media|
      filename = media.media_url_https.basename

      next unless filename =~ /jpg|jpeg/

      notice.photos.attach(io: open(media.media_url_https), filename: filename, content_type: "image/jpg")
    end

    notice.analyze!

    redirect_to prepare_notice_path(notice), notice: 'Eine Meldung mit Beweisfotos wurde importiert, bitte vervollständigen'
  end

  def prepare
    @notice = Notice.prepared_claim(params[:id])
  end

  def polish
    @notice = Notice.prepared_claim(params[:id])

    if @notice.update(notice_update_params)
      redirect_to public_charge_path(@notice), notice: 'Meldung wurde gespeichert und kann jetzt weitergeleitet werden'
    else
      render :prepare
    end
  end

  def upload
    notice = current_user.notices.from_param(params[:id])
    notice.assign_attributes(notice_upload_params)
    notice.save_incomplete!

    redirect_to [:edit, notice], notice: 'Beweisfotos wurden hochgeladen'
  end

  def share
    @notice = current_user.notices.from_param(params[:id])

    @mail = NoticeMailer.charge(@notice)
  end

  def status
    @notice = current_user.notices.from_param(params[:id])
    @notice.update!(status: :shared)

    redirect_to(notices_path, notice: "Deine Anzeige wurde als 'gemeldet' markiert.")
  end

  def mail
    notice = current_user.notices.from_param(params[:id])
    notice.update!(status: :shared)

    to = notice.district.all_emails.find {|email| email == params[:send_to]} || notice.district.email

    NoticeMailer.charge(notice, to).deliver_later

    redirect_to(notices_path, notice: "Deine Anzeige wird per E-Mail an #{to} versendet und als 'gemeldet' markiert.")
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
    @exif = @photo.service.download_file(@photo.key) { |file| EXIFAnalyzer.new.metadata(file) }
    @result = Annotator.new.annotate_object(@photo.key)
  end

  def colors
    @notice = current_user.notices.from_param(params[:id])
    @photo = @notice.photos.find(params[:photo_id])
  end

  def destroy
    notice = current_user.notices.destroyable.from_param(params[:id])
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
    notices = current_user.notices.open.where(id: params[:selected])

    case action
    when 'share'
      notices = notices.complete
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
        UserMailer.pdf(current_user, notices.pluck(:id)).deliver_later
        flash[:notice] = 'Die offenen, vollständigen Meldungen wurden als PDF generiert und per E-Mail zugeschickt'
      else
        flash[:notice] = 'Keine offenen, vollständigen Meldungen zum generieren gefunden!'
      end
    when 'status'
      notices = notices.complete
      if notices.present?
        notices.update(status: :shared)
        flash[:notice] = 'Die offenen, vollständigen Meldungen wurden als "gemeldet" markiert'
      else
        flash[:notice] = 'Keine offenen, vollständigen Meldungen zum markieren gefunden!'
      end
    when 'destroy'
      if notices.present?
        notices.destroy_all
        flash[:notice] = 'Die offenen Meldungen wurden gelöscht'
      else
        flash[:notice] = 'Keine offenen Meldungen zum löschen gefunden!'
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
    params.require(:notice).permit(:charge, :date, :date_date, :date_time, :registration, :brand, :color, :street, :zip, :city, :latitude, :longitude, :note, :duration, :severity, :vehicle_empty, :hazard_lights)
  end

  def notice_upload_params
    params.require(:notice).permit(photos: [])
  end

  def notice_import_params
    params.require(:notice).permit(:tweet_url)
  end
end
