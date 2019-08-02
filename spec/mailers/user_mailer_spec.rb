require "spec_helper"

describe UserMailer do
  describe "signup" do
    let(:user) { Fabricate(:user) }
    let(:mail) { UserMailer.signup(user) }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match("bestätige")
    end
  end
end
