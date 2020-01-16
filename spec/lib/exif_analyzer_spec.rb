require 'spec_helper'

describe EXIFAnalyzer, :vcr do
  let(:example) { File.open(file_fixture('truck.jpg')) }

  it "handles text annotations" do
    meta = EXIFAnalyzer.new.metadata(example)

    expect(meta[:date_time]).to eql('2020-01-15 07:52:58.000000000 +0100'.to_time)
    expect(meta[:altitude]).to be_nan
    expect(meta[:latitude]).to be_nan
    expect(meta[:longitude]).to be_nan
  end
end
