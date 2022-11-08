# frozen_string_literal: true

require 'spec_helper'

describe AutoreplyMailbox do
  let(:notice) { Fabricate.create(:notice) }

  context 'parsing' do
    it 'parses complex stuffs' do
      source = file_fixture('example.eml').read
      mail = Mail.from_source(source)
      expect(AutoreplyMailbox.content_from_mail(mail)).to eql("puffig\n\nknuffig\n")
    end
  end

  context 'processing' do
    it 'should process bounce if notice missing' do
      mail = receive_inbound_email_from_mail(
        to: 'unknown-notice-id@anzeige.weg.li',
        from: 'pk-dummertorf@schnapsschnarcherbayern.de',
      )
      expect(mail.bounced?).to be_truthy
    end

    it 'should process a reply' do
      expect do
        expect do
          receive_inbound_email_from_mail(
            to: notice.wegli_email,
            from: 'pk-dummertorf@schnapsschnarcherbayern.de',
            subject: 'Fwd: Status update?',
            body: <<~BODY,
              --- Begin forwarded message ---
              From: Uschi Müller <uschi@muller.com>

              What's the status?
            BODY
          )
        end.to change {
          notice.replies.count
        }.by(1)
      end.to have_enqueued_mail(UserMailer, :autoreply)
    end
  end
end
