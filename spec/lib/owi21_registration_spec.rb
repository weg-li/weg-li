# frozen_string_literal: true

require "spec_helper"

describe Owi21Registration do
  {
    "AT" => %w[A 2],
    "NL" => %w[NL 3],
    "CH" => %w[CH 5],
    "FR" => %w[F 6],
    "BE" => %w[B B],
    "PL" => %w[PL PL],
    "RO" => %w[RO RO],
    "GB" => %w[UK UK],
    "FI" => %w[FIN FIN],
    "IT" => %w[I I],
    "ES" => %w[E E],
    "PT" => %w[P P],
    "SE" => %w[S S],
    "NO" => %w[N N],
    "IE" => %w[IRL IRL],
    "HU" => %w[H H],
    "EE" => %w[EST EST],
    "SI" => %w[SLO SLO],
    "RS" => %w[SRB SRB],
    "ME" => %w[MNE MNE],
    "MK" => %w[NMK NMK],
    "UA" => %w[UA UA],
    "RU" => %w[RUS RUS],
    "JP" => %w[J J],
    "KR" => %w[ROK ROK],
    "CN" => %w[CHN CHN],
    "US" => %w[USA USA],
    "CA" => %w[CDN CDN],
    "AU" => %w[AUS AUS],
    "AR" => %w[RA RA],
    "BH" => %w[BRN BRN],
    "BZ" => %w[BH BH],
    "BI" => %w[RU RU],
    "SV" => %w[ES ES],
    "TZ" => %w[EAT EAT],
    "XK" => %w[RKS RKS],
  }.each do |country, (nation, type)|
    it "maps #{country} to vehicle nation #{nation} and plate type #{type}" do
      expect(described_class.attributes("(#{country}) AB-123-CD")).to eq(
        KFZ_Kennzeichen: "AB-123-CD",
        KFZ_Kennzeichen_Merkmal: type,
        KFZ_Kennzeichen_Nation: nation,
      )
    end
  end

  ["HÜB AB 123", "HH-AB 123", "BN X 1681 E"].each do |registration|
    it "retains German formatting for #{registration}" do
      expect(described_class.attributes(registration)).to eq(
        KFZ_Kennzeichen: Vehicle.normalize(registration, text_divider: "-"),
        KFZ_Kennzeichen_Merkmal: "1",
      )
    end
  end

  it "recognizes an explicit German ISO prefix without exporting it as part of the plate" do
    expect(described_class.attributes("(DE) HÜB AB 123")).to eq(KFZ_Kennzeichen: "HÜB-AB 123", KFZ_Kennzeichen_Merkmal: "1")
  end

  it "accepts a lowercase country tag without changing the plate's case" do
    expect(described_class.attributes("(gb) Ab12 XyZ")).to eq(KFZ_Kennzeichen: "Ab12 XyZ", KFZ_Kennzeichen_Merkmal: "UK", KFZ_Kennzeichen_Nation: "UK")
  end

  ["(UA) АА 1234 ВВ", "(JP) 品川あ12-34", "(GR) ΑΒΓ-1234"].each do |registration|
    it "preserves the original non-Latin characters in #{registration}" do
      plate = registration.split(") ", 2).last
      expect(described_class.attributes(registration).fetch(:KFZ_Kennzeichen)).to eq(plate)
    end
  end

  it "allows whitespace before the country tag" do
    expect(described_class.attributes("  (FR) AB-123-CD")).to include(KFZ_Kennzeichen: "AB-123-CD", KFZ_Kennzeichen_Nation: "F")
  end

  it "does not mistake a parenthesized German district for a country tag" do
    expect(described_class.attributes("(HH) AB 123")).to eq(KFZ_Kennzeichen: "HH-AB 123", KFZ_Kennzeichen_Merkmal: "1")
  end

  it "defines conversions only for recognized country tags" do
    expect(described_class::NATION_CODES.keys - described_class::COUNTRY_CODES).to be_empty
  end

  it "does not change the stored registration string" do
    registration = "(FR) AB-123-CD"
    described_class.attributes(registration)
    expect(registration).to eq("(FR) AB-123-CD")
  end

  it "keeps missing registrations consistent with German normalization" do
    expect(described_class.attributes(nil)).to eq(KFZ_Kennzeichen: "", KFZ_Kennzeichen_Merkmal: "1")
  end

  it "emits vehicle codes within the schema's three-character limit" do
    expect(described_class::NATION_CODES.values).to all(match(/\A[A-Z]{1,3}\z/))
  end
end
