# frozen_string_literal: true

require "rails_helper"

describe Export do
  let(:export) { Fabricate.build(:export) }

  context "validation" do
    it "is valid" do
      expect(export).to be_valid
    end
  end

  context "header" do
    it "is present" do
      expect(export.header).to eql(%i[start_date end_date tbnr street city zip latitude longitude])

      export = Fabricate.build(:export)
      expect(export.header).to be_present
    end
  end

  context "display_name" do
    it "is present" do
      export = Fabricate.build(:export)
      expect(export.display_name).to eql("moin")
    end
  end

  context "finders" do
    it "should have a scope for public" do
      export = Fabricate.create(:export)
      Fabricate.create(:export, user: Fabricate.create(:user))

      expect(Export.for_public.to_a).to eql([export])
    end
  end

  context "data" do
    it "should have data" do
      Fabricate.create(:notice, status: :shared)

      export = Fabricate.build(:export)
      export.data do |data|
        expect(data).to_not be_nil
      end
    end
  end
end
