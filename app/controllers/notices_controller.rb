class NoticesController < ApplicationController
  before_action :authenticate!
  before_action :authenticate_admin_user!, only: :inspect
  around_action :user_time_zone, if: :change_time_zone?

  def index
    @filter_status =  Notice.statuses.keys
    @order_created_at = 'ASC'
    @table_params = {}

    @notices = current_user.notices.page(params[:page])
    if filter = params[:filter]
      @table_params[:filter] = filter.to_unsafe_hash
      @notices = @notices.where(status: filter[:status]) if filter[:status]
    end
    if order = params[:order]
      @table_params[:order] = order.to_unsafe_hash
      if order[:created_at]
        @notices = @notices.reorder(created_at: order[:created_at])
        @order_created_at = 'DESC' if order[:created_at] == 'ASC'
      end
    end
  end

  def map
    @since = (params[:since] || '7').to_i

    @notices = current_user.notices.since(@since.days.ago)
  end

  def show
    @notice = current_user.notices.from_param(params[:id])
  end

  def new
    @notice = current_user.notices.build(date: Time.zone.today)
  end

  def create
    notice = current_user.notices.build(notice_params)
    notice.district = current_user.district
    notice.analyze!

    message = 'Eine Meldung mit Beweisfotos wurde erfasst'
    path = edit_notice_path(notice)
    if params[:another]
      message += ', nun gleich die nächste Meldung erfassen'
      path = new_notice_path
    else
      message += 'und Analyse gestartet'
    end

    redirect_to path, notice: message
  end

  def edit
    @notice = current_user.notices.from_param(params[:id])
  end

  def update
    @notice = current_user.notices.from_param(params[:id])

    if @notice.update(notice_params)
      path = params[:show] ? [@notice] : [:share, @notice]
      redirect_to path, notice: 'Meldung wurde gespeichert'
    else
      render :edit
    end
  end

  def upload
    notice = current_user.notices.from_param(params[:id])
    notice.assign_attributes(notice_params)
    notice.save_incomplete!

    redirect_to [:edit, notice], notice: 'Beweisfotos wurden hochgeladen'
  end

  def share
    @notice = current_user.notices.from_param(params[:id])
    @notice.district ||= current_user.district

    @mail = NoticeMailer.charge(current_user, @notice)
  end

  def mail
    @notice = current_user.notices.from_param(params[:id])
    @notice.assign_attributes(mail_params)

    if @notice.district.present?
      @notice.status = :shared
      @notice.save!

      NoticeMailer.charge(current_user, @notice).deliver_later

      redirect_to(notices_path, notice: t('notices.sent_via_email', recepients: @notice.district.email))
    else
      @notice.errors.add(:district, :blank)
      render :share
    end
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
        NoticeMailer.charge(current_user, notice).deliver_later
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

    redirect_back fallback_location: notice_path(notice), notice: 'Beweisfoto gelöscht'
  end

  private

  def notice_params
    params.require(:notice).permit(:charge, :date, :date_date, :date_time, :registration, :make, :brand, :model, :color, :kind, :address, :note, :hinder, :empty, :parked, :parked_long, photos: [])
  end

  def mail_params
    params.require(:notice).permit(:district)
  end
end
