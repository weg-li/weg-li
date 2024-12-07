# frozen_string_literal: true

require "spec_helper"

describe Annotator do
  it "annotates an image" do
    result = with_fixture("annotate") { subject.annotate_file }

    expect(result.keys).to eql(
      %i[
        face_annotations
        landmark_annotations
        logo_annotations
        label_annotations
        text_annotations
        safe_search_annotation
        image_properties_annotation
        error
        crop_hints_annotation
        full_text_annotation
        web_detection
        product_search_results
        context
        localized_object_annotations
      ],
    )
  end

  it "handles text annotations" do
    result = with_fixture("annotate") { subject.annotate_file }

    matches = Annotator.grep(result[:text_annotations]) { |key| key }
    expect(matches).to eql(
      [
        "Seliten",
        "H MBURGER",
        "STHALLE",
        "FUNSALL",
        "ites",
        "RD WN.200",
        "www.aevneke.de 043",
        "94849 80",
        "H",
        "MBURGER",
        "RD",
        "WN.200",
        "www.aevneke.de",
        "043",
        "94849",
        "80",
      ],
    )
  end

  it "handles label annotations" do
    result = with_fixture("annotate") { subject.annotate_file }

    label_annotations = result[:label_annotations]
    matches = Annotator.grep(label_annotations) { |key| key }
    expect(matches).to eql(
      ["Land vehicle", "Vehicle", "Car", "Luxury vehicle", "Automotive design", "Personal luxury car", "Mode of transport", "Transport", "Family car", "Automotive exterior"],
    )
  end

  it "handles logo annotations" do
    result = with_fixture("annotate") { subject.annotate_file }

    logo_annotations = result[:logo_annotations]
    matches = Annotator.grep(logo_annotations) { |key| key }
    expect(matches).to eql([])
  end

  it "handles colors" do
    result = with_fixture("annotate") { subject.annotate_file }

    expected = [["silver", 0.3093334957957268], ["black", 0.12371549755334854], ["silver", 0.10345552116632462]]
    expect(Annotator.dominant_colors(result)).to eql(expected)
  end

  it "handles unsafe" do
    result = with_fixture("annotate") { subject.annotate_file }

    expect(Annotator.unsafe?(result)).to be_falsey

    result = { safe_search_annotation: { adult: :LIKELY } }
    expect(Annotator.unsafe?(result)).to be_truthy
  end
end
