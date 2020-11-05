require 'spec_helper'

describe PDFGenerator do
  let(:example) { File.binread(file_fixture('anzeige.pdf')) }

  it "handles the pdf generation" do
    travel_to('20.01.2020 15:00:00 UTC'.to_time.utc) do
      district = Fabricate(:district, zip: '12345')
      user = Fabricate.build(:user, name: 'Uschi Müller', email: 'test@example.com', city: 'Dorf', zip: '12345', street: 'Am Weiher 123')
      notice = Fabricate.build(:notice, user: user, charge: 'doof parken', brand: 'märzer', color: 'black', registration: 'HH AB 123', city: 'Dorf', street: 'Am Weiher 123', zip: '12345', district: district, token: 'xxxxxxx')
      notice.save!

      result = PDFGenerator.new(quality: :original).generate(notice)

      # file_fixture('anzeige.pdf').binwrite(result)
      expect(example.size).to eql(result.size)
    end
  end

  it "handles weird characters" do
    broken_string = "Telefon: ‭015224026"
    notice = Fabricate(:notice, note: broken_string)

    expect { PDFGenerator.new.generate(notice) }.to_not raise_error
  end
end
