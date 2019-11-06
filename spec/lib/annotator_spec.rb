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

    expected = [
      ["beige", 0.4671035706996918],
      ["black", 0.18365518748760223],
      ["green", 0.004049558658152819],
      ["beige", 0.153400719165802],
      ["black", 0.05919218063354492],
      ["beige", 0.04759815335273743],
      ["gray", 0.028131773695349693],
      ["beige", 0.022791322320699692],
      ["black", 0.00767330639064312],
      ["beige", 0.006161436904221773],
    ]
    expect(Annotator.dominant_colors(result)).to eql(expected)
  end
end
