require "spec_helper"

describe NoticeMailer do
  let(:notice) { Fabricate(:notice) }
  let(:user) { notice.user }

  describe "charge" do
    it "renders the mail" do
      mail = NoticeMailer.charge(notice)

      expect(mail.subject).to match('Anzeige')
      expect(mail.to).to eq(notice.district.email)
      expect(mail.cc).to eq([user.email])
      expect(mail.reply_to).to eq([user.email])
      expect(mail.attachments.size).to be(1)
    end
  end
end
