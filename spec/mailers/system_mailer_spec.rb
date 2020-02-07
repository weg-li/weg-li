require "spec_helper"

describe SystemMailer do
  describe "reminder" do
    let(:notice) { Fabricate(:notice) }
    let(:mail) { SystemMailer.geocoding([notice.id]) }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq(['peter@weg-li.de'])
      expect(mail.body.encoded).to match("korrigiere")
    end
  end
end
