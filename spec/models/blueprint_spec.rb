# frozen_string_literal: true

require "rails_helper"

RSpec.describe Blueprint, type: :model do
  let(:blueprint) { Fabricate.build(:blueprint) }

  context "validation" do
    it "is valid" do
      expect(blueprint).to be_valid
    end
  end

  context "apply" do
    let(:notice) { Fabricate.build(:notice) }

    it "applies blueprint to notice" do
      notice.blueprint = blueprint

      notice.apply_blueprint
      expect(notice.flags).to eq(blueprint.flags)
      expect(notice.tbnr).to eq(blueprint.tbnr)
      expect(notice.note).to eq(blueprint.note)
    end
  end

  context "scope" do
    let!(:blueprint1) { Fabricate(:blueprint, name: "A", note: "AAAAA") }
    let!(:blueprint2) { Fabricate(:blueprint, name: "B", note: "BBBBB") }

    it "orders blueprints" do
      expect(Blueprint.ordered).to eq([blueprint2, blueprint1])
    end

    it "searches blueprints" do
      expect(Blueprint.search("A")).to eq([blueprint1])
      expect(Blueprint.search("B")).to eq([blueprint2])
      expect(Blueprint.search("C")).to eq([])
    end
  end
end
