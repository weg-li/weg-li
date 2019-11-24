require "spec_helper"

describe AutoreplyMailbox do
  let(:notice) { Fabricate.create(:notice) }

  context "processing" do
    it "should process a reply" do
      email = notice.unique_email_address
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
    end
  end
end
