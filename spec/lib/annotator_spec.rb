require 'spec_helper'

describe Annotator, :vcr do
  it "annotates an image" do
    result = with_fixture('annotate') { subject.annotate_file }

    expect(result.keys).to eql(
      [
        :face_annotations,
        :landmark_annotations,
        :logo_annotations,
        :label_annotations,
        :text_annotations,
        :safe_search_annotation,
        :image_properties_annotation,
        :error,
        :crop_hints_annotation,
        :full_text_annotation,
        :web_detection,
        :product_search_results,
        :context,
        :localized_object_annotations
      ]
    )
  end

  it "handles text annotations" do
    result = with_fixture('annotate') { subject.annotate_file }

    matches = Annotator.grep_text(result) { |key| key }
    expect(matches).to eql(
      ["Seliten", "H MBURGER", "STHALLE", "FUNSALL", "ites", "RD WN.200", "www.aevneke.de 043", "94849 80", "H", "MBURGER", "RD", "WN.200", "www.aevneke.de", "043", "94849", "80"]
    )
  end

  it "handles colors" do
    result = with_fixture('annotate') { subject.annotate_file }

    expected = ["silver", "black", "gray", "silver", "black", "gray", "gray", "white", "black", "gray"]
    expect(Annotator.dominant_colors(result)).to eql(expected)
  end

  private

  def with_fixture(fixture_name, record: !!ENV['RECORD_FIXTURE'])
    fixture_path = Pathname.new(File.join(file_fixture_path, "#{fixture_name}.dump"))

    return Marshal.load(fixture_path.read) if fixture_path.exist? && !record

    data = yield
    File.binwrite(fixture_path, Marshal.dump(data))
    data
  end
end
