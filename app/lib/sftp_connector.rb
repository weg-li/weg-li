# frozen_string_literal: true

require "net/sftp"

class SftpConnector
  class << self
    def create(config)
      config = config.to_s.upcase
      host = ENV.fetch("SFTP_HOST_#{config}")
      username = ENV.fetch("SFTP_USERNAME_#{config}")
      password = ENV["SFTP_PASSWORD_#{config}"]
      remote_directory = ENV.fetch("SFTP_REMOTE_DIRECTORY_#{config}", "/files/")
      private_key = ENV.fetch("SFTP_PRIVATE_KEY")
      passphrase = ENV["SFTP_PASSPHRASE"]
      port = ENV.fetch("SFTP_PORT", 22).to_i

      connection_options = private_key.include?("-----BEGIN") ? { key_data: [private_key] } : { keys: [private_key] }
      connection_options.merge!(
        port: port,
        password: password,
        passphrase: passphrase,
        auth_methods: ["publickey"],
      )

      new(
        host: host,
        username: username,
        remote_directory: remote_directory,
        connection_options: connection_options,
      )
    end
  end

  def initialize(host:, username:, remote_directory:, connection_options:)
    @host = host
    @username = username
    @remote_directory = remote_directory
    @connection_options = connection_options
  end

  def upload(io, remote_path)
    Net::SFTP.start(@host, @username, **@connection_options) do |sftp|
      sftp.upload!(io, remote_path)
    end
  end

  def upload_to_subfolder(io, subfolder, filename)
    Net::SFTP.start(@host, @username, **@connection_options) do |sftp|
      remote_subfolder = File.join(@remote_directory, subfolder)

      # If the directory already exists, ignore the error
      sftp.mkdir!(remote_subfolder) rescue Net::SFTP::StatusException

      sftp.upload!(io, File.join(remote_subfolder, filename))
    end
  end
end
