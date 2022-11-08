# frozen_string_literal: true

require 'spec_helper'

describe Vehicle do
  it 'it gets all the brands' do
    data = Vehicle.brands.first(3)
    expect(%w[Abarth Adria Aixam]).to eql(data)
  end

  it 'it gets all the models' do
    data = Vehicle.models('BMW').first(3)
    expect(%w[i3 i8 M3]).to eql(data)
  end

  it 'it gets all the plates' do
    data = Vehicle.plates.first(3)
    expect([%w[A Augsburg], ['AA', 'Ostalbkreis (Aalen)'], %w[AB Aschaffenburg]]).to eql(data)
  end

  it 'it gets the district for a plates prefix' do
    district = Vehicle.district_for_plate_prefix('HH PS 1234')
    expect(district).to eql('Hansestadt Hamburg')
  end

  it 'it normalizes strings' do
    expect(Vehicle.normalize('|_ HH EH 1327')).to eql('HH-EH-1327')
    expect(Vehicle.normalize('1.HH GK 6400')).to eql('HH-GK-6400')
    expect(Vehicle.normalize('HHoGK 6400')).to eql('HH-GK-6400')
    expect(Vehicle.normalize('BiGK 6400')).to eql('B-GK-6400')
  end

  it 'it checks possible plate matches' do
    sample = ' RD  WN.200 '
    result = Vehicle.plate?(sample)
    expect(result).to be_truthy
    expect(result).to eql(['RD WN 200', 1.0])

    expect(Vehicle.plate?('')).to be_falsy
    expect(Vehicle.plate?('RDD WN 200')).to be_falsy
    expect(Vehicle.plate?('XX WN 200')).to be_falsy
  end

  it 'realworld plate matches' do
    expect(Vehicle.plate?('RD WN.200')).to eql(['RD WN 200', 1.0])
    expect(Vehicle.plate?('»HH GB 382')).to eql(['HH GB 382', 1.0])
    expect(Vehicle.plate?('HHTX 1267')).to eql(['HHTX 1267', 0.8])
    expect(Vehicle.plate?('HH TX 1267', prefixes: ['HH'])).to eql(['HH TX 1267', 1.2])
    expect(Vehicle.plate?('HHTX 1267', prefixes: ['HH'])).to eql(['HH TX 1267', 1.1])
    expect(Vehicle.plate?('HHTX 1267', prefixes: ['PI'])).to eql(['HHTX 1267', 0.8])
    expect(Vehicle.plate?('.HHCG 142')).to eql(['HHCG 142', 0.8])
    expect(Vehicle.plate?('OHH NK 2121')).to eql(['HHNK 2121', 0.5])
    expect(Vehicle.plate?('AZ SJ59')).to eql(['AZ SJ 59', 1.0])
    expect(Vehicle.plate?('H:HS2127')).to eql(['H HS 2127', 1.0])
    expect(Vehicle.plate?('HHW2071')).to eql(['HHW 2071', 0.8])
    expect(Vehicle.plate?('„HH RH 2788')).to eql(['HH RH 2788', 1.0])
    expect(Vehicle.plate?('(.HH GE 216')).to eql(['HH GE 216', 1.0])
    expect(Vehicle.plate?('HHO TR 2607')).to eql(['HHTR 2607', 0.8])
    expect(Vehicle.plate?('BHH BT 4200')).to eql(['HHBT 4200', 0.5])
    expect(Vehicle.plate?('HK IP 5000')).to eql(['HK IP 5000', 1.0])
    expect(Vehicle.plate?('BN X 1681 E')).to eql(['BN X 1681E', 1.0])
    expect(Vehicle.plate?('MCL 3935E')).to eql(['MCL 3935E', 0.8])
    expect(Vehicle.plate?('MODX 7106')).to eql(['MDX 7106', 0.8])
    expect(Vehicle.plate?('CHHAA 1406')).to eql(['HHAA 1406', 0.5])
    expect(Vehicle.plate?('1.HH GK 6400')).to eql(['HH GK 6400', 1.0])
    expect(Vehicle.plate?('PHH TY 814')).to eql(['HHTY 814', 0.5])
    expect(Vehicle.plate?('DHH TY 814')).to eql(['HHTY 814', 0.5])
  end

  it 'most likely' do
    plates = [
      ['RD WN 200', 1.0],
      ['HHTX 1267', 0.8],
      ['HHNK 2121', 0.5],
    ].shuffle!
    expect(Vehicle.most_likely?(plates)).to eql('RD WN 200')

    plates = [
      ['RD WN 200', 1.0], ['HHTX 1267', 0.8],
      ['HHTX 1267', 0.8],
      ['HHNK 2121', 0.5], ['HHTX 1267', 0.8]
    ].shuffle!
    expect(Vehicle.most_likely?(plates)).to eql('HHTX 1267')
    expect(Vehicle.most_likely?([])).to eql(nil)
    expect(Vehicle.most_likely?(nil)).to eql(nil)
  end

  it 'most often' do
    colors = %w[
      gray
      gray
      gray
    ].shuffle!
    expect(Vehicle.most_often?(colors)).to eql('gray')

    expect(Vehicle.most_often?([])).to be_nil
    expect(Vehicle.most_often?(nil)).to be_nil
  end

  it 'it checks possible brand matches' do
    sample = 'SEAT'
    result = Vehicle.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql(['Seat', 1.0])

    sample = 'Iveco'
    result = Vehicle.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql(['IVECO', 1.0])

    sample = 'Volkswagen transporter t5'
    result = Vehicle.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql(['Volkswagen', 0.8])

    sample = '323 Combi'
    result = Vehicle.brand?(sample)
    expect(result).to be_truthy
    expect(result).to eql(['Mazda', 0.5])

    expect(Vehicle.brand?('')).to be_falsy
    expect(Vehicle.brand?('RDD WN 200')).to be_falsy
    expect(Vehicle.brand?('XX WN 200')).to be_falsy
  end

  it 'alias brand matches' do
    expect(Vehicle.brand?('vw')).to eql(['Volkswagen', 1.0])
  end

  it 'falsepositives brand matches' do
    expect(Vehicle.brand?('Minivan')).to be_falsy
  end
end
