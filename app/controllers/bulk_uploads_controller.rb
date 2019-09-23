class BulkUploadsController < ApplicationController
  before_action :authenticate!

  def index
    @order_created_at = 'ASC'
    @table_params = {}
    @filter_status = [:open, :done]

    @bulk_uploads = current_user.bulk_uploads.page(params[:page])
    if order = params[:order]
      @table_params[:order] = order.to_unsafe_hash
      if order[:created_at]
        @bulk_uploads = @bulk_uploads.reorder(created_at: order[:created_at])
        @order_created_at = 'DESC' if order[:created_at] == 'ASC'
      end
    end
  end

  def show
    @bulk_upload = current_user.bulk_uploads.find(params[:id])
  end

  def new
    @bulk_upload = current_user.bulk_uploads.build
  end

  def create
    bulk_upload = current_user.bulk_uploads.build(bulk_upload_params)

    bulk_upload.save!

    redirect_to edit_bulk_upload_path(bulk_upload), notice: 'Upload wurde angelegt'
  end

  def edit
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

    redirect_to bulk_uploads_path, notice: 'Es wurden bereits alle Fotos des Uploads verarbeitet' and return if @bulk_upload.photos.blank?
  end

  def update
    bulk_upload = current_user.bulk_uploads.find(params[:id])

    if params[:one_per_photo]
      photos = bulk_upload.photos
      photos.each do |photo|
        notice = current_user.notices.build(bulk_upload: bulk_upload)
        Notice.transaction do
          notice.save_incomplete!
          photo.update!(record: notice)
        end
        notice.analyze!
      end
    else
      photos = bulk_upload.photos.find(params[:bulk_upload][:photos])
      notice = current_user.notices.build(bulk_upload: bulk_upload)
      Notice.transaction do
        notice.save_incomplete!
        photos.each { |photo| photo.update!(record: notice) }
      end
      notice.analyze!
    end

    redirect_to edit_bulk_upload_path(bulk_upload), notice: 'Neue Meldung aus Fotos erzeugt'
  end

  def purge
    bulk_upload = current_user.bulk_uploads.from_param(params[:id])
    bulk_upload.photos.find(params[:photo_id]).purge

    redirect_back fallback_location: edit_bulk_upload_path(bulk_upload), notice: 'Foto gelöscht'
  end

  def destroy
    notice = current_user.bulk_uploads.find(params[:id])
    notice.destroy!

    redirect_to bulk_uploads_path, notice: 'Upload wurde gelöscht'
  end

  def bulk
    action = params[:bulk_action] || 'destroy'
    bulk_uploads = current_user.bulk_uploads.where(id: params[:selected])
    case action
    when 'destroy'
      bulk_uploads.destroy_all
      flash[:notice] = 'Die Uploads wurden gelöscht'
    end

    redirect_to bulk_uploads_path
  end

  private

  def bulk_upload_params
    params.require(:bulk_upload).permit(photos: [])
  end
end
