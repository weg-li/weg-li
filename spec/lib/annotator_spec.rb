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

  it "handles label annotations" do
    result = with_fixture('annotate') { subject.annotate_file }

    matches = Annotator.grep_label(result) { |key| key }
    expect(matches).to eql(
      ["Land vehicle", "Vehicle", "Car", "Luxury vehicle", "Automotive design", "Personal luxury car", "Mode of transport", "Transport", "Family car", "Automotive exterior"]
    )
  end

  it "handles colors" do
    result = with_fixture('annotate') { subject.annotate_file }

    expected = [["green", 0.07079581508600219], ["black", 0.011712757905458115], ["green", 9.747609883366086e-05], ["green", 0.00820852205658884], ["green", 0.0049693492691105234], ["green", 0.005661231598786953], ["green", 0.008403018787346173], ["white", 0.002472757692439098], ["green", 1.0412155768190021e-05], ["green", 9.887379997145819e-05]]
    expect(Annotator.dominant_colors(result)).to eql(expected)
  end
end
