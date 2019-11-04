class NoticesController < ApplicationController
  before_action :authenticate!
  before_action :authenticate_community_user!, only: [:prepare, :polish]
  before_action :authenticate_admin_user!, only: :inspect
  before_action :validate!, except: [:index]

  def index
    @filter_status =  Notice.statuses.keys
    @order_created_at = 'ASC'
    @order_registration = 'ASC'
    @table_params = {
      search: {},
      filter: {},
      order: {},
    }

    @notices = current_user.notices.page(params[:page])

    if search = params[:search]
      @table_params[:search] = search.to_unsafe_hash
      @notices = @notices.where('registration ILIKE :term', term: "%#{search[:term]}%") if search[:term].present?
    end
    if filter = params[:filter]
      @table_params[:filter] = filter.to_unsafe_hash
      @notices = @notices.where(status: filter[:status]) if filter[:status].present?
    end
    if order = params[:order]
      @table_params[:order] = order.to_unsafe_hash
      ordering = {}
      if order[:created_at].present?
        ordering[:created_at] = order[:created_at]
        @order_created_at = 'DESC' if order[:created_at] == 'ASC'
      end
      if order[:registration].present?
        ordering[:registration] = order[:registration]
        @order_registration = 'DESC' if order[:registration] == 'ASC'
      end
      @notices = @notices.reorder(ordering) if ordering.present?
    end
  end

  def map
    @since = (params[:since] || '7').to_i
    @display = params[:display] || 'cluster'
    @district = params[:district] || current_user.city

    @notices = current_user.notices.shared.since(@since.days.ago).joins(:district).where(districts: {name: @district})
    @active = @notices.map(&:user_id).uniq.size
    @default_district = District.from_zip(current_user.zip) || District.first
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

    if @notice.update(notice_params)
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

    import_user = User.new(nickname: nickname, name: tweet.user.name, address: tweet.user.location, access: :ghost)
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

    if @notice.update(notice_params)
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

  def mail
    @notice = current_user.notices.from_param(params[:id])

    @notice.status = :shared
    @notice.save!

    NoticeMailer.charge(@notice).deliver_later

    redirect_to(notices_path, notice: "Deine Anzeige wurde an #{@notice.district.email} versendet.")
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
    @result = Annotator.new.annotate_object(@photo.key)
  end

  def destroy
    notice = current_user.notices.destroyable.from_param(params[:id])
    notice.destroy!

    redirect_to notices_path, notice: t('notices.destroyed')
  end

  def bulk
    action = params[:bulk_action] || 'analyze'
    notices = current_user.notices.where(id: params[:selected])
    case action
    when 'share'
      notices.open.complete.each do |notice|
        NoticeMailer.charge(notice).deliver_later
        notice.update! status: :shared
      end
      flash[:notice] = 'Die noch offenen, vollständigen Meldungen werden im Hintergrund per E-Mail gemeldet'
    when 'analyze'
      notices.open.incomplete.each do |notice|
        notice.analyze!
      end
      flash[:notice] = 'Die Fotos der unvollständigen Meldungen werden im Hintergrund analysiert'
    when 'destroy'
      notices.open.destroy_all
      flash[:notice] = 'Die offenen Meldungen wurden gelöscht'
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
    notice.photos.find(params[:photo_id]).purge

    redirect_back fallback_location: notice_path(notice), notice: 'Foto gelöscht'
  end

  private

  def notice_params
    params.require(:notice).permit(:charge, :date, :date_date, :date_time, :registration, :brand, :color, :street, :zip, :city, :note, :duration, :severity, :empty)
  end

  def notice_upload_params
    params.require(:notice).permit(photos: [])
  end

  def notice_import_params
    params.require(:notice).permit(:tweet_url)
  end
end
