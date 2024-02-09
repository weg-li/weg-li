# frozen_string_literal: true

require "spec_helper"

describe ParkGenerator do
  let(:example) { File.binread(file_fixture("park.pdf")) }

  it "handles the pdf generation" do
    travel_to("20.01.2020 15:00:00 UTC".to_time.utc) do
      result = ParkGenerator.new.generate("🤷‍♂️ Hambüach")

      # file_fixture("park.pdf").binwrite(result)
      expect(example.size).to eql(result.size)
    end
  end
end
