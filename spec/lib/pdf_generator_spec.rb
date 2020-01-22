require 'spec_helper'

describe PDFGenerator, :vcr do
  let(:example) { File.binread(file_fixture('anzeige.pdf')) }

  it "handles the pdf generation" do
    travel_to('01.01.2020'.to_date) do
      district = Fabricate(:district, zip: '12345')
      user = Fabricate.build(:user, name: 'Uschi Müller', email: 'test@example.com', city: 'Dorf', zip: '12345', street: 'Am Weiher 123')
      notice = Fabricate.build(:notice, user: user, charge: 'doof parken', brand: 'märzer', color: 'black', registration: 'HH AB 123', city: 'Dorf', street: 'Am Weiher 123', zip: '12345', district: district, token: 'xxxxxxx')
      notice.save!

      result = PDFGenerator.new.generate(notice)

      expect(example).to eql(result)
    end
  end
end
