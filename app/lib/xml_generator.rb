# frozen_string_literal: true

require "builder"

class XmlGenerator
  PREFIX_WINOWIG = "XMLDE"

  def generate(notice, template = :winowig, locals = {})
    locals = locals.merge({ notice:, user: notice.user, now: Time.zone.now })
    renderer.render(template: "/public/#{template}", formats: [:xml], locals:)
  end

  private

  def renderer
    @renderer ||= ApplicationController.renderer.new(
      http_host: Rails.application.config.default_host,
      https: true,
    )
  end
end
