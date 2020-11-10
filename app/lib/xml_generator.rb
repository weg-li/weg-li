require 'builder'

class XMLGenerator
  def generate(notice)
    renderer.render(template: "/public/winowig", formats: [:xml], locals: { :"@notice" => notice })
  end

  private

  def renderer
    @renderer ||= ApplicationController.renderer.new(http_host: 'www.weg-li.de', https: true)
  end
end
