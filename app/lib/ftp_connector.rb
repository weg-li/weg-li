# frozen_string_literal: true

require "net/sftp"

class FTPConnector
  def initialize(host:, username:, private_key:, port: 22, passphrase: nil)
    @host = host
    @username = username
    @private_key = private_key
    @port = port
    @passphrase = passphrase
  end

  def upload(local_path, remote_path)
    Net::SFTP.start(@host, @username, **connection_options) do |sftp|
      sftp.upload!(local_path, remote_path)
    end
  end

  def upload_to_subfolder(local_path, remote_directory, subfolder: Date.current.strftime("%Y_%m_%d"))
    Net::SFTP.start(@host, @username, **connection_options) do |sftp|
      remote_subfolder = File.join(remote_directory, subfolder)
      create_remote_directory(sftp, remote_subfolder)
      sftp.upload!(local_path, File.join(remote_subfolder, File.basename(local_path)))
    end
  end

  private

  def create_remote_directory(sftp, path)
    sftp.mkdir!(path)
  rescue Net::SFTP::StatusException
    sftp.stat!(path)
  end

  def connection_options
    key_options =
      if @private_key.include?("-----BEGIN")
        { key_data: [@private_key] }
      else
        { keys: [@private_key] }
      end

    key_options.merge(
      port: @port,
      passphrase: @passphrase,
      auth_methods: ["publickey"],
    )
  end
end
