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

    bulk_upload.save!

    redirect_to edit_bulk_upload_path(bulk_upload), notice: 'Upload wurde angelegt'
  end

  def edit
    @bulk_upload = current_user.bulk_uploads.find(params[:id])
    @notices = @bulk_upload.photos.map { |photo| @bulk_upload.notices.build(photos: [photo], address: 'blaaaa') }
  end

  def update
    @bulk_upload = current_user.bulk_uploads.find(params[:id])

    if @bulk_upload.update(bulk_upload_params)
      redirect_to path, notice: 'Upload wurde gespeichert'
    else
      render :edit
    end
  end


  def destroy
    notice = current_user.bulk_uploads.find(params[:id])
    notice.destroy!

    redirect_to bulk_uploads_path, notice: 'Upload wurde gelöscht'
  end

  private

  def bulk_upload_params
    params.require(:bulk_upload).permit(photos: [])
  end
end
