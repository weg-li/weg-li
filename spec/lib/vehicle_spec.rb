require 'spec_helper'

describe Vehicle do
  it "loads all the data" do
    expect(Vehicle.cars).to have(39).elements
  end

  it "it gets all the brands" do
    data = Vehicle.brands.first(3)
    expect(["Alfa Romeo", "Audi", "BMW"]).to eql(data)
  end

  it "it gets all the models" do
    data = Vehicle.models("BMW").first(3)
    expect(["i3", "i8", "M3"]).to eql(data)
  end

  it "it gets all the plates" do
    data = Vehicle.plates.first(3)
    expect([["A", "Augsburg"], ["AA", "Ostalbkreis (Aalen)"], ["AB", "Aschaffenburg"]]).to eql(data)
  end

  it "it checks possible plate matches" do
    sample = " RD  WN.200 "
    result = Vehicle.plate?(sample)
    expect(result).to be_truthy
    expect(result).to eql("RD WN 200")

    expect(Vehicle.plate?("")).to be_falsy
    expect(Vehicle.plate?("RDD WN 200")).to be_falsy
    expect(Vehicle.plate?("RD 200")).to be_falsy
    expect(Vehicle.plate?("XX WN 200")).to be_falsy
  end

  it "realworld matches" do
    expect(Vehicle.plate?("RD WN.200")).to eql("RD WN 200")
  end
end
