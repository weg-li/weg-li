# frozen_string_literal: true

require "spec_helper"

describe SftpJob do
  before do
    stub_request(:get, /images\.weg\.li/).to_return(status: 200, body: file_fixture("truck.jpg").read)
  end

  context "perform" do
    # run with env vars for testing: SFTP_HOST_WUPPERTAL, SFTP_USERNAME_WUPPERTAL, SFTP_PASSWORD_WUPPERTAL, SFTP_PRIVATE_KEY, SFTP_PASSPHRASE
    it "handles the upload" do
      district = Fabricate(:district, zip: "17098", ags: "08311000", config: :wuppertal)
      user = Fabricate.build(:user, name: "Uschi Müller", email: "test@example.com", city: "Dorf", zip: "17098", street: "Am Weiher 123", appendix: "2. OG", phone: "0178123456", date_of_birth: "31.12.2000")
      charge = Fabricate.build(:charge, tbnr: "142170", description: "Parken auf einem unbeschilderten Radweg")
      notice = Fabricate.build(:notice, user:, charge:, brand: "märzer", color: "black", registration: "HÜB AB 123", city: "Dorf", street: "Am Weiher 123", zip: "17098", district:)
      notice.save!
      notice.photos.first.update!(key: "test.jpg")

      SftpJob.perform_now(notice)
    end

    it "calls the uploader" do
      ENV["SFTP_HOST_WUPPERTAL"] = "sftp.example.com"
      ENV["SFTP_USERNAME_WUPPERTAL"] = "uploader"
      ENV["SFTP_PASSWORD_WUPPERTAL"] = "secret"
      ENV["SFTP_PRIVATE_KEY"] = "/path/to/private_key"
      ENV["SFTP_PASSPHRASE"] = "secret"

      double = instance_double(SftpConnector)
      allow(SftpConnector).to receive(:create).and_return(double)
      allow(double).to receive(:upload_to_subfolder)

      notice = Fabricate(:notice)
      SftpJob.perform_now(notice)

      expect(double).to have_received(:upload_to_subfolder)
    end
  end
end
