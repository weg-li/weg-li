require 'spec_helper'

describe XMLGenerator do
  context "winowig" do
    let(:example) { File.read(file_fixture('anzeige-winowig.xml')) }

    it "handles the xml generation" do
      travel_to('20.01.2020 15:00:00 UTC'.to_time.utc) do
        district = Fabricate(:district, zip: '12345')
        user = Fabricate.build(:user, name: 'Uschi Müller', email: 'test@example.com', city: 'Dorf', zip: '54321', street: 'Am Weiher 123')
        notice = Fabricate.build(:notice, user: user, charge: Charge.plain_charges.first, brand: 'märzer', color: 'black', registration: 'HH AB 123', city: 'Dorf', street: 'Am Weiher 123', zip: '12345', district: district, token: 'xxxxxxx')
        notice.save!
        notice.photos.first.update!(key: 'test.jpg')

        result = XMLGenerator.new(template: :winowig).generate(notice)

        # file_fixture('anzeige.xml').write(result)
        expect(example).to eql(result)
      end
    end
  end

  context "owi21" do
    let(:example) { File.read(file_fixture('anzeige-owi21.xml')) }

    it "handles the xml generation" do
      travel_to('20.01.2020 15:00:00 UTC'.to_time.utc) do
        district = Fabricate(:district, zip: '12345')
        user = Fabricate.build(:user, name: 'Uschi Müller', email: 'test@example.com', city: 'Dorf', zip: '54321', street: 'Am Weiher 123')
        notice = Fabricate.build(:notice, user: user, charge: Charge.plain_charges.first, brand: 'märzer', color: 'black', registration: 'HH AB 123', city: 'Dorf', street: 'Am Weiher 123', zip: '12345', district: district, token: 'xxxxxxx')
        notice.save!
        notice.photos.first.update!(key: 'test.jpg')

        result = XMLGenerator.new(template: :owi21).generate(notice)

        # file_fixture('anzeige.xml').write(result)
        expect(example).to eql(result)
      end
    end
  end
end
