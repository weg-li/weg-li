# frozen_string_literal: true

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

  describe "validate" do
    let(:user) { Fabricate(:user) }
    let(:mail) { UserMailer.validate(user) }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match("bestätige")
    end
  end

  describe "activate" do
    let(:user) { Fabricate(:user) }
    let(:mail) { UserMailer.activate(user) }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match("löschen")
    end
  end

  describe "signup_link" do
    let(:email) { "mursksi@furksi.de" }
    let(:mail) { UserMailer.signup_link(email, "123ABC") }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([email])
      expect(mail.body.encoded).to match("zum Registrieren")
    end
  end

  describe "login_link" do
    let(:user) { Fabricate(:user) }
    let(:email) { user.email }
    let(:mail) { UserMailer.login_link(user, "123ABC") }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([email])
      expect(mail.body.encoded).to match("zum Einloggen")
    end
  end

  describe "reminder" do
    let(:notice) { Fabricate(:notice) }
    let(:user) { notice.user }
    let(:mail) { UserMailer.reminder(user, [notice.id]) }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match("schnellstmöglichst")
    end
  end

  describe "reminder_bulk_upload" do
    let(:bulk_upload) { Fabricate(:bulk_upload) }
    let(:user) { bulk_upload.user }
    let(:mail) { UserMailer.reminder_bulk_upload(user, [bulk_upload.id]) }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match("rechtzeitig")
    end
  end

  describe "pdf" do
    let(:notice) { Fabricate(:notice) }
    let(:user) { notice.user }
    let(:mail) { UserMailer.pdf(user, [notice.id]) }

    before do
      stub_request(:get, /images\.weg\.li/).to_return(status: 200, body: file_fixture("mercedes.jpg").read)
    end

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([user.email])
      expect(mail.attachments.size).to be(1)
    end
  end

  describe "pdf" do
    let(:user) { Fabricate(:user) }
    let(:export) { Fabricate(:export, user:) }
    let(:mail) { UserMailer.export(export) }

    it "renders the mail" do
      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([user.email])
    end
  end

  describe "autoreply" do
    let(:inbound_email) { create_inbound_email_from_fixture("example.eml", status: :delivered) }
    let(:reply) { Fabricate(:reply) }
    let(:user) { reply.notice.user }

    it "renders the mail" do
      reply.update! action_mailbox_inbound_email: inbound_email
      mail = UserMailer.autoreply(user, reply)

      expect(mail.subject).to_not be_nil
      expect(mail.to).to eq([user.email])
      expect(mail.attachments.size).to be(1)
    end
  end
end
