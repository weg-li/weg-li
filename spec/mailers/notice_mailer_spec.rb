require "spec_helper"

describe NoticeMailer do
  let(:notice) { Fabricate(:notice) }
  let(:user) { notice.user }

  describe "charge" do
    it "renders the mail" do
      notice.recipients = 'uschi@muschi.de, hans@franz.de'

      mail = NoticeMailer.charge(user, notice)

      expect(mail.subject).to match('Anzeige')
      expect(mail.to).to eq(["uschi@muschi.de", "hans@franz.de"])
      expect(mail.cc).to eq([user.email])
      expect(mail.reply_to).to eq([user.email])
      expect(mail.attachments).to have(1).elements
    end
  end
end
