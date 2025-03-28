# frozen_string_literal: true

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
  def download_file(key, &)
    instrument :streaming_download, key: key do
      File.open(path_for(key), 'rb', &)
    end
  end
end

ActiveSupport::Reloader.to_prepare do
  require 'active_storage/blob'

  class ActiveStorage::Blob
    before_validation :set_usable_key_not_the_shait_from_active_storate

    def set_usable_key_not_the_shait_from_active_storate
      # REM: add a file-extension to the key .jpg
      self[:key] ||= "#{SecureRandom.base36(28)}#{File.extname(self[:filename])}" if self[:filename].present?
    end
  end

  require 'active_storage/direct_uploads_controller'

  ActiveStorage::DirectUploadsController.instance_eval do
    rescue_from(ActionController::InvalidAuthenticityToken, with: -> { redirect_to('/', alert: 'Deine Sitzung wurde unerwartet beendet!') })
  end
end
