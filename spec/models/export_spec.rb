# frozen_string_literal: true

require "rails_helper"

describe Export do
  let(:export) { Fabricate.build(:export) }

  context "validation" do
    it "is valid" do
      expect(export).to be_valid
    end
  end

  context "fields" do
    it "is present" do
      expect(export.send(:notices_fields)).to eql(%i[start_date end_date tbnr street city zip latitude longitude])
      export.user = Fabricate.create(:user)
      expect(export.send(:notices_fields)).to eql(%i[token status registration brand color street city zip location tbnr note start_date end_date latitude longitude vehicle_empty hazard_lights expired_tuv expired_eco over_2_8_tons])
    end
  end

  context "display_name" do
    it "is present" do
      travel_to("20.01.2020 15:00:00 UTC".to_time.utc) do
        Time.use_zone("UTC") do
          export = Fabricate.build(:export)
          expect(export.display_name).to eql("notices csv 20.01.2020 16:00")
        end
      end
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
