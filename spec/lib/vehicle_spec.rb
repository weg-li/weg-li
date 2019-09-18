require 'spec_helper'

describe Vehicle do
  it "loads all the data" do
    expect(Vehicle.cars.size).to be(40)
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

  it "it normalizes strings" do
    expect(Vehicle.normalize("|_ HH EH 1327")).to eql("HH-EH-1327")
  end

  it "it checks possible plate matches" do
    sample = " RD  WN.200 "
    result = Vehicle.plate?(sample)
    expect(result).to be_truthy
    expect(result).to eql("RD WN 200")

    expect(Vehicle.plate?("")).to be_falsy
    expect(Vehicle.plate?("RDD WN 200")).to be_falsy
    expect(Vehicle.plate?("XX WN 200")).to be_falsy
  end

  it "realworld plate matches" do
    expect(Vehicle.plate?("RD WN.200")).to eql("RD WN 200")
    expect(Vehicle.plate?("HHTX 1267")).to eql("HHTX 1267")
    expect(Vehicle.plate?(".HHCG 142")).to eql("HHCG 142")
    expect(Vehicle.plate?("OHH NK 2121")).to eql("HHNK 2121")
    expect(Vehicle.plate?("AZ SJ59")).to eql("AZ SJ 59")
    expect(Vehicle.plate?("H:HS2127")).to eql("H HS 2127")
    expect(Vehicle.plate?("HHW2071")).to eql("HHW 2071")
    expect(Vehicle.plate?("„HH RH 2788")).to eql("HH RH 2788")
  end


  it "it checks possible brand matches" do
    sample = "SEAT"
    result = Vehicle.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql("Seat")

    sample = "323 Combi"
    result = Vehicle.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql("Mazda")

    expect(Vehicle.brand?("")).to be_falsy
    expect(Vehicle.brand?("RDD WN 200")).to be_falsy
    expect(Vehicle.brand?("XX WN 200")).to be_falsy
  end

  it "alias brand matches" do
    expect(Vehicle.brand?("vw")).to eql("Volkswagen")
  end

  # it "realworld brand matches" do
  #   expect(Vehicle.brand?("vw")).to eql("RD WN 200")
  # end
end
