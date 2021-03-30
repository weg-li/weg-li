require 'spec_helper'

describe DataSet do
  CAR_ML_RESULT = {"suggestions"=>{"license_plate_number"=>["HH RG 365"], "make"=>["Audi"], "color"=>["gray_silver"]}}
  let(:data_set) { Fabricate.build(:data_set, data: read_fixture) }

  context "validation" do
    it "is valid" do
      expect(data_set).to be_valid
    end
  end

  context "registrations" do
    it "reads registrations from google vision" do
      expect(data_set.registrations).to eql([["RD WN 200", 1.0], ["WN 200", 0.8]])
    end

    it "reads registrations from car_ml" do
      data_set = Fabricate.build(:data_set, kind: :car_ml, data: CAR_ML_RESULT)
      expect(data_set.registrations).to eql(["HH RG 365"])
    end
  end

  context "brands" do
    it "reads brands from google vision" do
      expect(data_set.brands).to eql([])
    end

    it "reads brands from car_ml" do
      data_set = Fabricate.build(:data_set, kind: :car_ml, data: CAR_ML_RESULT)
      expect(data_set.brands).to eql(["Audi"])
    end
  end

  context "colors" do
    it "reads colors from google vision" do
      expect(data_set.colors).to eql([["silver", 0.3093334957957268], ["black", 0.12371549755334854], ["silver", 0.10345552116632462]])
    end

    it "reads colors from car_ml" do
      data_set = Fabricate.build(:data_set, kind: :car_ml, data: CAR_ML_RESULT)
      expect(data_set.colors).to eql(["gray_silver"])
    end
  end
end
