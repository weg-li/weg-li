# frozen_string_literal: true

require "spec_helper"

describe SftpConnector do
  let(:sftp) { instance_double(Net::SFTP::Session) }
  let(:connector) do
    described_class.new(
      host: "sftp.example.com",
      username: "uploader",
      remote_directory: "/files/",
      connection_options: {
        password: "secret",
        private_key: "/path/to/private_key",
        passphrase: "secret",
        port: 22,
      },
    )
  end

  # run with env vars for testing: SFTP_HOST_WUPPERTAL, SFTP_USERNAME_WUPPERTAL, SFTP_PASSWORD_WUPPERTAL, SFTP_PRIVATE_KEY, SFTP_PASSPHRASE
  it "executes an SFTP upload with the correct parameters in real life", skip: true do
    connector = described_class.create(:wuppertal)
    filename = "import.zip"
    file = file_fixture(filename)
    subfolder = Time.zone.now.strftime("%Y_%m_%d")
    connector.upload_to_subfolder(file, subfolder, filename)
  end

  it "uploads a file over SFTP using a private key" do
    allow(Net::SFTP).to receive(:start).and_yield(sftp)
    allow(sftp).to receive(:upload!).with("/tmp/report.zip", "/incoming/report.zip")

    connector.upload("/tmp/report.zip", "/incoming/report.zip")

    expect(Net::SFTP).to have_received(:start).with(
      "sftp.example.com",
      "uploader",
      password: "secret",
      private_key: "/path/to/private_key",
      passphrase: "secret",
      port: 22,
    )
    expect(sftp).to have_received(:upload!).with("/tmp/report.zip", "/incoming/report.zip")
  end

  it "defaults the subfolder to the current date" do
    allow(Net::SFTP).to receive(:start).and_yield(sftp)
    allow(sftp).to receive(:mkdir!).with("/files/incoming")
    allow(sftp).to receive(:upload!).with("/tmp/report.zip", "/files/incoming/report.zip")

    connector.upload_to_subfolder("/tmp/report.zip", "/incoming", "report.zip")
  end
end
