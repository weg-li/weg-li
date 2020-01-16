require "spec_helper"

describe AutoreplyMailbox do
  let(:notice) { Fabricate.create(:notice) }

  context "parsing" do
    it "parses complex stuffs" do
      source = file_fixture('example.eml').read
      mail = Mail.from_source(source)
      expect(AutoreplyMailbox.content_from_mail(mail)).to eql("puffig\n\nknuffig\n")
    end
  end

  context "processing" do
    it "should process a reply" do
      email = notice.wegli_email
      expect {
        expect {
          receive_inbound_email_from_mail \
            to: email,
            from: 'pk-dummertorf@schnapsschnarcherbayern.de',
            subject: "Fwd: Status update?",
            body: <<~BODY
              --- Begin forwarded message ---
              From: Frank Holland <frank@microsoft.com>

              What's the status?
            BODY
        }.to change {
          notice.replies.count
        }.by(1)
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
