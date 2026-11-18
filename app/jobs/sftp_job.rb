# frozen_string_literal: true

class SftpJob < ApplicationJob
  def perform(notice)
    config = notice.district.config
    generator = ZipGenerator.new(notice, :winowig)
    data = generator.generate

    sftp_connector = SftpConnector.create(config)
    subfolder = Time.zone.now.strftime("%Y_%m_%d")
    sftp_connector.upload_to_subfolder(data, subfolder, generator.filename)
  end
end
