require 'prawn'
require 'prawn/qrcode'

class ViolationGenerator
  def generate(name)
    pdf = Prawn::Document.new(page_size: 'A5') do |document|
      document.move_down(25)

      Rails.root.join('app/assets/images/parkraummanagement.png').open { |file| document.image(file, fit: [50, 50], at: [document.bounds.width - 50, document.cursor - 15]) }

      document.fill_color '333333'
      document.move_down(25)

      document.text(name, size: 14)
      document.text("Parkraum-Management", size: 14)

      document.move_down(50)
      document.text(
        "Sehr geehrte Verkehrsteilnehmer:innen,

        es wurde festgestellt, dass Sie gegen Verkehrsvorschriften verstoßen haben.

        In Kürze werden Sie (ggf. der Halter) einen Bescheid mit weiteren Einzelheiten erhalten und haben dann die Gelegenheit, sich zum Sachverhalt zu äußern. Nutzen Sie hierfür dann gerne auch die Möglichkeit der Online-Anhörung.

        Bitte sehen Sie vor Zugang des Bescheides von Zahlungen/Nachfragen ab.


        Nur ankreuzen, wenn zutreffend:",
        size: 10,
        inline_format: true,
      )

      document.move_down(20)
      document.fill_rectangle [0, document.cursor], 20, 20
      document.fill_color 'FFFFFF'
      document.fill_rectangle [2, document.cursor - 2], 16, 16
      document.fill_color '333333'
      document.text_box("Wegen verkehrsbehindernden Parkens wurde das Beiseiteräumen Ihres Fahrzeuges angeordnet; ein Abschleppauftrag wurde erteilt", size: 10, at: [30, document.cursor], width: document.bounds.width - 30)

      document.move_down(30)
      document.text_box("Sie haben die Kosten für die Anfahrt des Abschleppwagens auch dann zu tragen, wenn Sie Ihr Kraftfahrzeug vor dessen Eintreffen entfernen.", size: 10, at: [30, document.cursor], width: document.bounds.width - 30)


      document.move_down(90)

      document.text(name, size: 12)
      document.text("PARKRAUM-MANAGEMENT", size: 12)


      qr_code = RQRCode::QRCode.new(Rails.application.routes.url_helpers.violation_url(Rails.configuration.action_mailer.default_url_options))
      document.render_qr_code(qr_code, pos: [document.bounds.width - 50, document.cursor + 30])
    end

    pdf.render
  end
end
