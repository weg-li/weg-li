class BulkUploadsController < ApplicationController
  before_action :authenticate!

  def index
    @order_created_at = 'ASC'
    @table_params = {}

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
    bulk_upload.analyze!

    redirect_to edit_bulk_upload_path(bulk_upload), notice: 'Massen-Upload wurde angelegt'
  end

  def edit
    session[:bulk_upload_order_column] = @order_column = params[:order_column] || session[:bulk_upload_order_column] || 'filename'
    session[:bulk_upload_order_direction] = @order_direction = params[:order_direction] || session[:bulk_upload_order_direction] || 'asc'
    @bulk_upload = current_user.bulk_uploads.find(params[:id])
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
      bulk_upload.update! status: :done

      redirect_to notices_path, notice: 'Neue Meldungen wurden erzeugt'
    elsif params[:bulk_upload]
      photos = bulk_upload.photos.find(bulk_upload_update_photo_ids)
      notice = current_user.notices.build(bulk_upload: bulk_upload)
      Notice.transaction do
        notice.save_incomplete!
        photos.each { |photo| photo.update!(record: notice) }
      end
      notice.analyze!

      if bulk_upload.reload.photos.present?
        redirect_to edit_bulk_upload_path(bulk_upload), notice: 'Neue Meldung aus Fotos erzeugt'
      else
        bulk_upload.update! status: :done

        redirect_to notices_path, notice: 'Neue Meldung aus Fotos erzeugt, der Massen-Upload wurde vollständig zugeordnet'
      end
    else
      redirect_to edit_bulk_upload_path(bulk_upload), alert: 'Es wurde kein Foto ausgewählt'
    end
  end

  def purge
    bulk_upload = current_user.bulk_uploads.find(params[:id])
    bulk_upload.purge_photo!(params[:photo_id])

    redirect_back fallback_location: edit_bulk_upload_path(bulk_upload), notice: 'Foto gelöscht'
  end

  def destroy
    bulk_upload = current_user.bulk_uploads.find(params[:id])
    bulk_upload.destroy!

    redirect_to bulk_uploads_path, notice: 'Massen-Upload wurde gelöscht'
  end

  def bulk
    action = params[:bulk_action] || 'destroy'
    bulk_uploads = current_user.bulk_uploads.where(id: params[:selected])
    case action
    when 'destroy'
      bulk_uploads.destroy_all
      flash[:notice] = 'Die Massen-Uploads wurden gelöscht'
    end

    redirect_to bulk_uploads_path
  end

  def import
    bulk_upload = current_user.bulk_uploads.build(status: :processing)
    bulk_upload.save(validate: false)
    shared_album_url = params.require(:bulk_upload).require(:shared_album_url)

    PhotosDownloadJob.perform_later(bulk_upload, shared_album_url)

    redirect_to edit_bulk_upload_path(bulk_upload), notice: 'Massen-Upload wurde angelegt, Beweisfotos werden importiert'
  end

  private

  def bulk_upload_update_photo_ids
    params.require(:bulk_upload).require(:photos)
  end

  def bulk_upload_params
    params.require(:bulk_upload).permit(photos: [])
  end
end
