require 'spec_helper'

describe ApplicationHelper do
  context "markdown" do
    it "renders markdown" do
      expect(helper.markdown("moin _klaus_")).to eql("<p>moin <em>klaus</em></p>\n")
    end

    it "handles linebreaks" do
      expect(helper.markdown("moin\nklaus")).to eql("<p>moin<br>\nklaus</p>\n")
    end
  end

  context "title" do
    it "creates a proper title" do
      helper.set_title("specific", "unspecific")
      expect(helper.title("least specific")).to eql("specific · unspecific · least specific")
    end
  end

  context "render_cached" do
    let(:article) { Fabricate.build(:article, id: 123, updated_at: Time.utc(2015, 1, 1, 0, 0, 0)) }
    before { allow(helper).to receive_messages(action_name: 'test') }

    it "caches a scoped key" do
      allow(helper).to receive(:cache).with("de/test/test", {expires_in: 86400, skip_digest: true})

      helper.render_cached
    end

    it "caches passed keys" do
      allow(helper).to receive(:cache).with("de/hallo/klaus", {expires_in: 86400, skip_digest: true})

      helper.render_cached(:hallo, :klaus)
    end

    it "caches using cache_key" do
      allow(article).to receive(:new_record?) { false }
      allow(helper).to receive(:cache).with("de/articles/123-20150101000000000000", {expires_in: 86400, skip_digest: true})

      helper.render_cached(article)
    end
  end

end
