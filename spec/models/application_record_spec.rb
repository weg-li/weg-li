# frozen_string_literal: true

require "spec_helper"

describe ApplicationRecord do
  let(:notice) { Fabricate.build(:notice) }

  context "translation" do
    it "handles the attribute names" do
      expect(Notice.human_enum_name(:status, :open)).to eql("offen")
      expect(Notice.human_enum_name(:status, nil)).to eql(nil)
      expect(Notice.human_enum_name(:status, nil, default: "-")).to eql("-")
      expect(notice.translate_enum(:status)).to eql("offen")
    end
  end
end
