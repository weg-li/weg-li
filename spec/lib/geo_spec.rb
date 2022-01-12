require 'spec_helper'

describe Geo do
  it "it checks if a point is included" do
    geo = Geo.new([[50.0, 50.0], [50.0, 55.0], [55.0, 55.0]])

    expect(geo.contains?([50.0, 49.9])).to be_falsey
    expect(geo.contains?([50.0, 50.0])).to be_truthy
    expect(geo.contains?([51.0, 51.0])).to be_truthy
    expect(geo.contains?([52.0, 52.0])).to be_truthy
    expect(geo.contains?([53.0, 50.0])).to be_falsey
    expect(geo.contains?([54.0, 50.0])).to be_falsey
    expect(geo.contains?([55.0, 50.0])).to be_falsey
    expect(geo.contains?([50.0, 51.0])).to be_truthy
    expect(geo.contains?([50.0, 52.0])).to be_truthy
    expect(geo.contains?([50.0, 53.0])).to be_truthy
    expect(geo.contains?([50.0, 54.0])).to be_truthy
    expect(geo.contains?([50.0, 55.0])).to be_falsey
    expect(geo.contains?([50.0, 55.1])).to be_falsey
  end

  it "loads all PIs with a region" do
    expect(Geo.regions.size).to be(25)
    expect(Geo.regions.first.first).to be(:pi11)
    expect(Geo.suggest_email([48.07, 11.67])).to eql('pp-mue.muenchen.pi28@polizei.bayern.de')
  end

  it "calculates the distance between 2 points" do
    district = Fabricate.build(:district, latitude: 53, longitude: 9)
    notice = Fabricate.build(:notice)

    expect(Geo.distance(district, notice)).to be_within(0.00001).of(57.814660206076)
  end
end
