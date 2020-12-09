require 'prawn'
require 'prawn/qrcode'

class ParkGenerator
  def generate(name)
    pdf = Prawn::Document.new do |document|
      document.fill_color '333333'
      Rails.root.join('app/assets/images/stadtreinigung.png').open { |file| document.image(file, fit: [100, 100], at: [document.bounds.width - 150, document.cursor]) }

      document.move_down(100)
      document.fill_color 'ff0000'
      document.fill_rectangle [0, document.cursor], document.bounds.width / 2, 20
      document.fill_color 'ffffff'
      document.text_box(name.upcase, size: 12, at: [0, document.cursor], width: document.bounds.width / 2, height: 20, align: :center, valign: :center)

      document.move_down(20)
      document.fill_color 'bbbbbb'
      document.fill_rectangle [0, document.cursor], document.bounds.width / 2, 20
      document.fill_color 'ffffff'
      document.text_box("Freie Fahrt muss sein!", size: 12, at: [0, document.cursor], width: document.bounds.width / 2, height: 20, align: :center, valign: :center)

      document.move_down(20)
      document.fill_color '333333'
      text = "<i>Sie haben Ihr Fahrzeug verkehrsbehindernd abgestellt.

        <color rgb='ff0000'>Das bedeutet: Der Einsatz von Stadtreinigung und Feuerwehr wird erheblich eingeschränkt.</color></i>"
      document.text_box(text, size: 14, at: [0, document.cursor], width: document.bounds.width / 2, height: 200, valign: :bottom, inline_format: true)
      Rails.root.join('app/assets/images/feuerwehr.jpg').open { |file| document.image(file, at: [document.bounds.width / 2, document.cursor], fit: [document.bounds.width / 2, document.bounds.width / 2]) }

      document.move_down(250)
      document.fill_color '333333'
      document.text(
        "Damit verursachen Sie folgende Probleme:

        Ein reibungsloser Ablauf der Müllabfuhr ist mehr möglich, weil die Großen Entsorgungsfahrzeuge mehr Rangierraum benötigen.
        <color rgb='ff0000'>Konsequenz: Die Abfallgefäße können nicht termingerecht geleert werden - Aufwand und Kosten der Müllabfuhr erhöhen sich.</color>

        Fahrzeuge der Feuerwehr können bei Notfällen nicht schnell genug zum Einsatzort kommen.
        <color rgb='ff0000'>Konsequenz: Löscharbeiten und andere Noteinsätze verzögern sich - und das kann unter Umständen sogar Menschenleben gefährden.</color>

        Wir bitten Sie daher, Ihr Fahrzeug in Zukunft so zu parken, dass die Fahrzeuge von Stadtreinigung, Feuerwehr und Rettungsdiensten nicht behindert werden.


        Vielen Dank für Ihr Verständnis,
        #{name}",
        size: 12,
        inline_format: true,
      )

      qr_code = RQRCode::QRCode.new("https://www.weg-li.de")
      document.render_qr_code(qr_code, pos: [document.bounds.width - 50, 50])
    end

    pdf.render
  end
end
