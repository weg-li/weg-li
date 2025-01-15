# frozen_string_literal: true

require "spec_helper"

describe ZipValidator do
  it "validates a valid zip" do
    expect(ZipValidator.valid?(nil)).to be_falsey
    expect(ZipValidator.valid?("")).to be_falsey
    expect(ZipValidator.valid?("1234")).to be_falsey
    expect(ZipValidator.valid?(" 17098 ")).to be_falsey
    expect(ZipValidator.valid?("12345")).to be_falsey
    expect(ZipValidator.valid?("17098")).to be_truthy
  end
end
