class NoticesController < ApplicationController
  before_action :authenticate!
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

  def show
    @notice = current_user.notices.from_param(params[:id])
  end

  def new
    @notice = current_user.notices.build(date: Time.zone.today)
  end

  def create
    @notice = current_user.notices.build(notice_params)
    @notice.save_incomplete!

    action = params[:another] ? :new : :edit
    redirect_to [action, @notice], notice: 'Meldung wurde gespeichert'
  end

  def edit
    @notice = current_user.notices.from_param(params[:id])
  end

  def update
    @notice = current_user.notices.from_param(params[:id])

    if @notice.update(notice_params)
      path = params[:show] ? [@notice] : [:share, @notice]
      redirect_to path, notice: 'Meldung wurde vollständig gespeichert'
    else
      render :edit
    end
  end

  def share
    @notice = current_user.notices.from_param(params[:id])
    @notice.recipients = current_user.district.email

    @mail = NoticeMailer.charge(current_user, @notice.recipients, @notice)
  end

  def mail
    @notice = current_user.notices.from_param(params[:id])
    @notice.assign_attributes(mail_params)

    if @notice.recipients.present?
      NoticeMailer.charge(current_user, @notice).deliver
      @notice.update! status: :shared

      redirect_back(fallback_location: notices_path, notice: t('notices.sent_via_email', recepients: recepients.to_sentence))
    else
      @notice.errors.add(:recipients, :blank)
      render :share
    end
  end

  def enable
    @notice = current_user.notices.from_param(params[:id])
    @notice.update! status: :open

    redirect_to notices_path, notice: t('notices.enabled')
  end

  def disable
    @notice = current_user.notices.from_param(params[:id])
    @notice.update! status: :disabled

    redirect_to notices_path, notice: t('notices.disabled')
  end

  def destroy
    @notice = current_user.notices.from_param(params[:id])
    @notice.destroy!

    redirect_to notices_path, notice: t('notices.destroyed')
  end

  def bulk
    action = params[:bulk_action] || 'destroy'
    notices = current_user.notices.where(id: params[:selected])
    case action
    when 'destroy'
      flash[:notice] = t('notices.bulk_destroyed')
      notices.destroy_all
    end

    redirect_to notices_path
  end

  def analyse
    notice = current_user.notices.from_param(params[:id])

    if notice.analysing?
      redirect_back fallback_location: notice_path(notice), notice: 'Analyse läuft bereits'
    else
      notice.status = :analysing
      notice.save_incomplete!
      AnalyzerJob.perform_async(notice)

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
    params.require(:notice).permit(:charge, :date, :registration, :make, :brand, :model, :color, :kind, :address, :empty, :parked, photos: [])
  end

  def mail_params
    params.require(:notice).permit(:recipients)
  end
end
