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
  ActiveStorage::Blob.class_eval do
    callback = _validation_callbacks.any? do |cb|
      cb.kind == :before && cb.filter == :set_usable_key_not_the_shait_from_active_storate
    end
    before_validation :set_usable_key_not_the_shait_from_active_storate unless callback

    def set_usable_key_not_the_shait_from_active_storate
      # REM: add a file-extension to the key .jpg
      return unless self[:filename].present?

      extension = File.extname(self[:filename].to_s)
      return if extension.blank?
      return if self[:key].present? && File.extname(self[:key]).present?

      self[:key] = "#{SecureRandom.base36(28)}#{extension}"
    end
  end

  ActiveStorage::DirectUploadsController.class_eval do
    rescue_from(ActionController::InvalidAuthenticityToken, with: -> { redirect_to('/', alert: 'Deine Sitzung wurde unerwartet beendet!') })
  end
end
