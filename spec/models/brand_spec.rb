# frozen_string_literal: true

require "spec_helper"

describe Brand do
  before(:all) do
    Brand.connection.truncate("brands")
    Vehicle.cars.each do |item|
      params = {
        name: item["brand"],
        token: item["brand"].parameterize,
        kind: :car,
        aliases: item["aliases"] || [],
        models: item["models"] || [],
        falsepositives: item["falsepositives"] || [],
      }
      Brand.create!(params)
    end
  end

  after(:all) do
    Brand.connection.truncate("brands")
  end

  let(:model) { Fabricate.build(:brand) }

  context "validation" do
    it "is valid" do
      expect(model).to be_valid
    end
  end

  it "it checks possible brand matches" do
    sample = "SEAT"
    result = Brand.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql(["Seat", 1.0])

    sample = "Volkswagen transporter t5"
    result = Brand.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql(["Volkswagen", 0.8])

    sample = "323 Combi"
    result = Brand.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql(["Mazda", 0.5])

    expect(Brand.brand?("")).to be_falsy
    expect(Brand.brand?("RDD WN 200")).to be_falsy
    expect(Brand.brand?("XX WN 200")).to be_falsy
  end

  it "alias brand matches" do
    expect(Brand.brand?("vw")).to eql(["Volkswagen", 1.0])
  end

  it "falsepositives brand matches" do
    expect(Brand.brand?("Minivan")).to be_falsy
  end
end
