require "spec_helper"

describe AutoreplyMailbox do
  let(:notice) { Fabricate.create(:notice) }

  context "parsing" do
    it "parses complex stuffs" do
      source = "Received: by mx0049p1mdw1.sendgrid.net with SMTP id N7vZLjBvld Mon, 25 Nov 2019 18:19:53 +0000 (UTC)\nReceived: from mail-il1-f173.google.com (mail-il1-f173.google.com [209.85.166.173]) by mx0049p1mdw1.sendgrid.net (Postfix) with ESMTPS id 9154DA86F80 for <196a81bc60f01e18b861aa6b88997162-asdflkadsf@parse.weg-li.de>; Mon, 25 Nov 2019 18:19:52 +0000 (UTC)\nReceived: by mail-il1-f173.google.com with SMTP id f6so11091632ilh.9 for <196a81bc60f01e18b861aa6b88997162-asdflkadsf@parse.weg-li.de>; Mon, 25 Nov 2019 10:19:52 -0800 (PST)\nDKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=googlemail.com; s=20161025; h=mime-version:from:date:message-id:subject:to; bh=hUXJyPNsfkMe+S3w8U+8i/QQOPmTU0cU394Pwlg7Oic=; b=Ft+1houN03ucDUamflNWsFAyD6HAeeAPlPr94aTTI7iJp2KfVcvx5KzcljUl4j9geY qYt0fklANz7YPzOlQ/6jg9aRyLN6UE/L0bgjwKbXrYEYrKOjGukONU6aqYzMjxqtxyPK 9/YHk+0Hs2BvtyWyWE8xqPYD25gan6P1D1hvZAZIBESR7lc3JCBEGjb+1kAfl2Aji9hg fuDJpRR6z3y7pNU8C54pIqoW9fmArqtOxDkcOCRuXASf35fIETY7blq5vP9jysjcR+kB YKcQol9QEhvtcqaV0Sff2Cu2NLB3+QHIXVHow3BBmIU77oJ3ndl1PdLzPOjGboydf0SH 8VXA==\nX-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=1e100.net; s=20161025; h=x-gm-message-state:mime-version:from:date:message-id:subject:to; bh=hUXJyPNsfkMe+S3w8U+8i/QQOPmTU0cU394Pwlg7Oic=; b=eH5iru/Q4u+WP0Lic2IlT/iwhTwGmdidPTzEeoDRTFLV2MfRWkaelWLngRee9IrIpf sU15dMT+fygMK4Ckj1NtUxpGqQm+YZB0ggUeeP9kFRRSm5H35SDIjdzDekRX/7wvHPir 5ILBdflGzcFK4fTy2RRJad7au0qDaAtNVGMlisFDdAXTeHWQGZKb2duJ108vosxacW7N AnZzsNNg9S3kFX6roSxxr/lGyHNPajcligDFpM+eQSx2jw37a2HlVcv6EIbO9VN2GFIb dlcCk68fgiBi1dCrLO0sfGutjMGat6gKWzLvkSlWiZQXkC3u7pwZaMuhiPdvViZhrgPo NoAw==\nX-Gm-Message-State: APjAAAX7k63LyDuen2I0MyunHrEjGH4gxZ+BKc23Hr2G/bB4PqhNPFBf EjOwMW3AjF4mwQ7WiI/o/r6ShFppKqN7/v+VMaOoqmOu\nX-Google-Smtp-Source: APXvYqxyey0mTd/tNPfuwhLYgsYAKXjF1LRUsHPyq89oiVxw9j/EDcIm4d0UVxRlHn6oCbg+cIYSsagAqkJgfAO+hA4=\nX-Received: by 2002:a92:d746:: with SMTP id e6mr34429824ilq.111.1574705991866; Mon, 25 Nov 2019 10:19:51 -0800 (PST)\nMIME-Version: 1.0\nFrom: =?UTF-8?Q?peter_schr=C3=B6der?= <phoetmail@googlemail.com>\nDate: Mon, 25 Nov 2019 19:19:40 +0100\nMessage-ID: <CAFXhQ-t9uGGhJzBkVY-WMGg5MRVCNOqqdDnG=_HDtXezFr25vA@mail.gmail.com>\nSubject: tuffig\nTo: 196a81bc60f01e18b861aa6b88997162-asdflkadsf@parse.weg-li.de\nContent-Type: multipart/alternative; boundary=\"000000000000455f1105982fcfb1\"\n\n--000000000000455f1105982fcfb1\nContent-Type: text/plain; charset=\"UTF-8\"\n\npuffig\r\n\r\nknuffig\n\n--000000000000455f1105982fcfb1\nContent-Type: text/html; charset=\"UTF-8\"\n\n<div dir=\"ltr\"><div>puffig</div><div><br></div><div>knuffig<br></div></div>\n\n--000000000000455f1105982fcfb1--\n"

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
