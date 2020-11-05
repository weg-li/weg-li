require 'builder'

class XMLGenerator
  def generate(notice)
    renderer.render(template: "/public/dresden.xml.builder", locals: { :"@notice" => notice })
  end

  private

  def renderer
    @renderer ||= ApplicationController.renderer.new(http_host: 'www.weg-li.de', https: true)
  end
end
