# frozen_string_literal: true

module DataHelper
  def with_fixture(fixture_name, record: !ENV["RECORD_FIXTURE"].nil?)
    fixture_path = Rails.root.join("spec/fixtures/files/#{fixture_name}.dump")

    return Marshal.load(fixture_path.read) if fixture_path.exist? && !record

    data = yield
    File.binwrite(fixture_path, Marshal.dump(data))
    data
  end

  def read_fixture(fixture_name = "annotate")
    fixture_path = Rails.root.join("spec/fixtures/files/#{fixture_name}.dump")
    Marshal.load(fixture_path.read)
  end
end
