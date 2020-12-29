require 'spec_helper'

describe ViolationGenerator do
  let(:example) { File.binread(file_fixture('violation.pdf')) }

  it "handles the pdf generation" do
    travel_to('20.01.2020 15:00:00 UTC'.to_time.utc) do
      result = ViolationGenerator.new.generate("Hambuach")

      # file_fixture('violation.pdf').binwrite(result)
      expect(example.size).to eql(result.size)
    end
  end
end
