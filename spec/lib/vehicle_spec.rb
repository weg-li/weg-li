# frozen_string_literal: true

require "spec_helper"

describe Vehicle do
  it "it gets all the plates" do
    data = Vehicle.plates.first(3)
    expect([%w[A Augsburg], ["AA", "Ostalbkreis (Aalen)"], %w[AB Aschaffenburg]]).to eql(data)
  end

  it "it gets the district for a plates prefix" do
    district = Vehicle.district_for_plate_prefix("HH-PS 1234")
    expect(district).to eql("Hansestadt Hamburg")
  end

  it "it normalizes strings" do
    expect(Vehicle.normalize("|_ HH EH 1327")).to eql("HH-EH 1327")
    expect(Vehicle.normalize(" RD  WN.200 ")).to eql("RD-WN 200")
    expect(Vehicle.normalize("1.HH GK 6400")).to eql("HH-GK 6400")
    expect(Vehicle.normalize("HHoGK 6400")).to eql("HH-GK 6400")
    expect(Vehicle.normalize("BiGK 6400")).to eql("B-GK 6400")
    expect(Vehicle.normalize("Gö X 2656")).to eql("GÖ-X 2656")
    expect(Vehicle.normalize("Gö X 2656E")).to eql("GÖ-X 2656E")
    expect(Vehicle.normalize("AZ SJ59")).to eql("AZ-SJ 59")
  end

  it "it checks possible plate matches" do
    sample = " RD  WN.200 "
    result = Vehicle.plate?(sample)
    expect(result).to be_truthy
    expect(result).to eql(["RD-WN 200", 1.0])

    expect(Vehicle.plate?("")).to be_falsy
    expect(Vehicle.plate?("RDD-WN 200")).to be_falsy
    expect(Vehicle.plate?("XX-WN 200")).to be_falsy
  end

  it "realworld plate matches" do
    expect(Vehicle.plate?("GÖ TY 814")).to eql(["GÖ-TY 814", 1.0])
    expect(Vehicle.plate?("Gö TY 814")).to eql(["GÖ-TY 814", 1.0])
    expect(Vehicle.plate?("RD WN.200")).to eql(["RD-WN 200", 1.0])
    expect(Vehicle.plate?("»HH GB 382")).to eql(["HH-GB 382", 1.0])
    expect(Vehicle.plate?("HHTX 1267")).to eql(["H-HTX 1267", 0.8])
    expect(Vehicle.plate?("HH TX 1267", prefixes: ["HH"])).to eql(["HH-TX 1267", 1.2])
    expect(Vehicle.plate?("HHTX 1267", prefixes: ["HH"])).to eql(["HH-TX 1267", 1.1])
    expect(Vehicle.plate?("HHTX 1267", prefixes: ["PI"])).to eql(["H-HTX 1267", 0.8])
    expect(Vehicle.plate?(".HHCG 142")).to eql(["H-HCG 142", 0.8])
    expect(Vehicle.plate?("OHH NK 2121")).to eql(["HH-NK 2121", 0.5])
    expect(Vehicle.plate?("AZ SJ59")).to eql(["AZ-SJ 59", 1.0])
    expect(Vehicle.plate?("H:HS2127")).to eql(["H-HS 2127", 1.0])
    expect(Vehicle.plate?("HHW2071")).to eql(["H-HW 2071", 0.8])
    expect(Vehicle.plate?("„HH RH 2788")).to eql(["HH-RH 2788", 1.0])
    expect(Vehicle.plate?("(.HH GE 216")).to eql(["HH-GE 216", 1.0])
    expect(Vehicle.plate?("HHO TR 2607")).to eql(["HH-TR 2607", 0.8])
    expect(Vehicle.plate?("BHH BT 4200")).to eql(["HH-BT 4200", 0.5])
    expect(Vehicle.plate?("HK IP 5000")).to eql(["HK-IP 5000", 1.0])
    expect(Vehicle.plate?("BN X 1681 E")).to eql(["BN-X 1681E", 1.0])
    expect(Vehicle.plate?("MCL 3935E")).to eql(["M-CL 3935E", 0.8])
    expect(Vehicle.plate?("MODX 7106")).to eql(["M-DX 7106", 0.8])
    expect(Vehicle.plate?("CHHAA 1406")).to eql(["H-HAA 1406", 0.5])
    expect(Vehicle.plate?("1.HH GK 6400")).to eql(["HH-GK 6400", 1.0])
    expect(Vehicle.plate?("PHH TY 814")).to eql(["HH-TY 814", 0.5])
    expect(Vehicle.plate?("DHH TY 814")).to eql(["HH-TY 814", 0.5])
  end

  it "most likely" do
    plates = [
      ["RD-WN 200", 1.0],
      ["HHTX 1267", 0.8],
      ["HHNK 2121", 0.5],
    ].shuffle!
    expect(Vehicle.most_likely?(plates)).to eql("RD-WN 200")

    plates = [
      ["RD-WN 200", 1.0], ["HHTX 1267", 0.8],
      ["HHTX 1267", 0.8],
      ["HHNK 2121", 0.5], ["HHTX 1267", 0.8]
    ].shuffle!
    expect(Vehicle.most_likely?(plates)).to eql("HHTX 1267")
    expect(Vehicle.most_likely?([])).to eql(nil)
    expect(Vehicle.most_likely?(nil)).to eql(nil)
  end

  it "most often" do
    colors = %w[
      gray
      gray
      gray
    ].shuffle!
    expect(Vehicle.most_often?(colors)).to eql("gray")

    expect(Vehicle.most_often?([])).to be_falsy
    expect(Vehicle.most_often?(nil)).to be_falsy
  end
end
