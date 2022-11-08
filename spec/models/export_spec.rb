# frozen_string_literal: true

require 'rails_helper'

describe Export do
  let(:export) { Fabricate.build(:export) }

  context 'validation' do
    it 'is valid' do
      expect(export).to be_valid
    end
  end

  context 'header' do
    it 'is present' do
      expect(export.header).to eql(%i[date charge street city zip latitude longitude])

      Export.export_types.each_key do |export_type|
        export = Fabricate.build(:export, export_type:)
        expect(export.header).to be_present
      end
    end
  end

  context 'data' do
    it 'should have data' do
      Fabricate.create(:notice, status: :shared)

      Export.export_types.each_key do |export_type|
        export = Fabricate.build(:export, export_type:)
        export.data do |data|
          expect(data).to_not be_nil
        end
      end
    end
  end
end
