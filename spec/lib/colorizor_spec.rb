# frozen_string_literal: true

require 'spec_helper'

describe Colorizor do
  it 'finds closest color' do
    colors = [
      ['silver', { red: 155.0, green: 161.0, blue: 166.0, alpha: nil }],
      ['black', { red: 19.0, green: 20.0, blue: 21.0, alpha: nil }],
      ['green', { red: 71.0, green: 85.0, blue: 53.0, alpha: nil }],
      ['silver', { red: 180.0, green: 186.0, blue: 190.0, alpha: nil }],
      ['gray', { red: 50.0, green: 49.0, blue: 50.0, alpha: nil }],
      ['gray', { red: 121.0, green: 122.0, blue: 124.0, alpha: nil }],
      ['gray', { red: 84.0, green: 85.0, blue: 86.0, alpha: nil }],
      ['white', { red: 241.0, green: 243.0, blue: 242.0, alpha: nil }],
      ['black', { red: 13.0, green: 20.0, blue: 35.0, alpha: nil }],
      ['gray', { red: 164.0, green: 152.0, blue: 137.0, alpha: nil }],
    ]
    colors.each do |(name, color)|
      expect(Colorizor.closest_match(color)).to eql(name)
    end
  end
end
