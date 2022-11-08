# frozen_string_literal: true

require 'builder'

class XMLGenerator
  def initialize(template: 'winowig')
    @template = template
  end

  def generate(notice)
    locals = {
      '@notice': notice,
      '@user': notice.user,
    }
    renderer.render(template: "/public/#{@template}", formats: [:xml], locals:)
  end

  private

  def renderer
    @renderer ||= ApplicationController.renderer.new(http_host: Rails.application.config.default_host, https: true)
  end
end
