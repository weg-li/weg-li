ActiveStorage.service_urls_expire_in = 1.week

require 'active_storage/downloader'
require 'active_storage/direct_uploads_controller'

ActiveStorage::DirectUploadsController.instance_eval do
  rescue_from(ActionController::InvalidAuthenticityToken, with: lambda { redirect_to('/', alert: 'Deine Sitzung wurde unerwartet beendet!') })
end

ActiveStorage::RepresentationsController.instance_eval do
  rescue_from(MiniMagick::Error, with: lambda { redirect_to(request.url) })
  rescue_from(ActiveRecord::RecordNotFound, with: lambda { head(404) })
end

require 'active_storage/service/gcs_service'
require 'active_storage/service/disk_service'

class ActiveStorage::Service::GCSService
  def download_file(key)
    instrument :download, key: key do
      io = file_for(key).download
      io.rewind

      yield io
    end
  end
end

class ActiveStorage::Service::DiskService
  def download_file(key)
    instrument :streaming_download, key: key do
      File.open(path_for(key), "rb") do |file|
        yield file
      end
    end
  end
end
