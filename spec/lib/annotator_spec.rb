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

    expected = [["blue", 0.3093334957957268], ["black", 0.12371549755334854], ["darkgreen", 0.014060177141800523], ["blue", 0.10345552116632462], ["black", 0.07157249003648758], ["blue", 0.08326810225844383], ["blue", 0.16341691743582487], ["blue", 0.06564345024526119], ["black", 0.004515119246207178], ["red", 0.011104317614808679]]
    expect(Annotator.dominant_colors(result)).to eql(expected)
  end
end
