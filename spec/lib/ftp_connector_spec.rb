# frozen_string_literal: true

require "spec_helper"
require_relative "../../app/lib/ftp_connector"

describe FTPConnector do
  let(:sftp) { instance_double(Net::SFTP::Session) }
  let(:connector) do
    described_class.new(
      host: "sftp.example.com",
      username: "uploader",
      private_key: "/path/to/private_key",
    )
  end

  it "uploads a file over SFTP using a private key" do
    allow(Net::SFTP).to receive(:start).and_yield(sftp)
    allow(sftp).to receive(:upload!).with("/tmp/report.zip", "/incoming/report.zip")

    connector.upload("/tmp/report.zip", "/incoming/report.zip")

    expect(Net::SFTP).to have_received(:start).with(
      "sftp.example.com",
      "uploader",
      keys: ["/path/to/private_key"],
      port: 22,
      passphrase: nil,
      auth_methods: ["publickey"],
    )
    expect(sftp).to have_received(:upload!).with("/tmp/report.zip", "/incoming/report.zip")
  end

  it "passes private key contents directly to SSH" do
    key = "-----BEGIN OPENSSH PRIVATE KEY-----\nkey-data\n-----END OPENSSH PRIVATE KEY-----"
    connector = described_class.new(host: "sftp.example.com", username: "uploader", private_key: key)
    allow(Net::SFTP).to receive(:start).and_yield(sftp)
    allow(sftp).to receive(:upload!)

    connector.upload("/tmp/report.zip", "/incoming/report.zip")

    expect(Net::SFTP).to have_received(:start).with(
      "sftp.example.com",
      "uploader",
      key_data: [key],
      port: 22,
      passphrase: nil,
      auth_methods: ["publickey"],
    )
  end

  it "creates the requested subfolder and uploads the file into it" do
    allow(Net::SFTP).to receive(:start).and_yield(sftp)
    allow(sftp).to receive(:mkdir!).with("/incoming/reports")
    allow(sftp).to receive(:upload!).with("/tmp/report.zip", "/incoming/reports/report.zip")

    connector.upload_to_subfolder("/tmp/report.zip", "/incoming", subfolder: "reports")

    expect(sftp).to have_received(:mkdir!).with("/incoming/reports")
    expect(sftp).to have_received(:upload!).with("/tmp/report.zip", "/incoming/reports/report.zip")
  end

  it "defaults the subfolder to the current date" do
    allow(Date).to receive(:current).and_return(Date.new(2026, 11, 12))
    allow(Net::SFTP).to receive(:start).and_yield(sftp)
    allow(sftp).to receive(:mkdir!).with("/incoming/2026_11_12")
    allow(sftp).to receive(:upload!).with("/tmp/report.zip", "/incoming/2026_11_12/report.zip")

    connector.upload_to_subfolder("/tmp/report.zip", "/incoming")

    expect(sftp).to have_received(:mkdir!).with("/incoming/2026_11_12")
    expect(sftp).to have_received(:upload!).with("/tmp/report.zip", "/incoming/2026_11_12/report.zip")
  end
end
