require 'spec_helper'

describe Notice do
  let(:notice) { Fabricate.build(:notice) }

  context "validation" do
    it "is valid" do
      expect(notice).to be_valid
    end
  end

  context "duplication" do
    it "duplicates a notice" do
      notice = Fabricate(:notice)
      expect {
        notice.duplicate!
      }.to change {
        Notice.count
      }.by(1)
    end
  end

  context "apply_favorites" do
    it "applies favorites" do
      existing_notice = Fabricate.create(:notice, status: :shared, registration: 'HH PS 123')

      notice.apply_favorites(['HH PS 123'])

      expect(notice.registration).to eql('HH PS 123')
      expect(notice.brand).to eql(existing_notice.brand)
      expect(notice.color).to eql(existing_notice.color)
      expect(notice.charge).to eql(existing_notice.charge)
    end
  end

  context "incomplete" do
    it "is incomplete" do
      expect(notice).to be_complete
      notice.charge = nil
      expect(notice).to be_invalid
      notice.save_incomplete!
      expect(notice.reload).to be_incomplete
    end
  end

  context "defaults" do
    it "is valid" do
      notice = Fabricate(:notice)
      expect(notice).to be_open
      expect(notice.token).to be_present
    end
  end
end
