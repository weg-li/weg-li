# frozen_string_literal: true

require "spec_helper"

describe "OWI21 foreign registration export" do
  {
    "(PL) PL-A 1233" => ["PL-A 1233", "PL", "PL"],
    "(FR) AB-123-CD" => %w[AB-123-CD F 6],
    "(NL) 12-ABC-D" => %w[12-ABC-D NL 3],
    "(UA) АА 1234 ВВ" => ["АА 1234 ВВ", "UA", "UA"],
    "(JP) 品川あ12-34" => %w[品川あ12-34 J J],
    "(GB) AB12 CDE" => ["AB12 CDE", "UK", "UK"],
  }.each do |registration, (plate, nation, type)|
    it "exports #{registration} losslessly in both the model and generated XML" do
      notice = Fabricate(:notice, registration:)
      expect(notice.owi21_args).to include(KFZ_Kennzeichen: plate, KFZ_Kennzeichen_Nation: nation, KFZ_Kennzeichen_Merkmal: type)
      xml = Nokogiri::XML(XmlGenerator.new.generate(notice, :owi21))
      expect(xml.errors).to be_empty
      vehicle = xml.at_xpath("//owi:Bestand", "owi" => "http://www.owi21.de")
      expect(vehicle["KFZ_Kennzeichen"]).to eq(plate)
      expect(vehicle["KFZ_Kennzeichen_Nation"]).to eq(nation)
      expect(vehicle["KFZ_Kennzeichen_Merkmal"]).to eq(type)
      expect(notice.reload.registration).to eq(registration)
    end
  end

  it "escapes XML attribute characters without changing their values" do
    notice = Fabricate(:notice, registration: '(FR) AB"&123-CD')
    xml = Nokogiri::XML(XmlGenerator.new.generate(notice, :owi21))
    expect(xml.errors).to be_empty
    expect(xml.at_xpath("//owi:Bestand", "owi" => "http://www.owi21.de")["KFZ_Kennzeichen"]).to eq('AB"&123-CD')
  end
end
