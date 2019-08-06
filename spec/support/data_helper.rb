module DataHelper
  def with_fixture(fixture_name, record: !!ENV['RECORD_FIXTURE'])
    fixture_path = Pathname.new(File.join(file_fixture_path, "#{fixture_name}.dump"))

    return Marshal.load(fixture_path.read) if fixture_path.exist? && !record

    data = yield
    File.binwrite(fixture_path, Marshal.dump(data))
    data
  end
end
