# frozen_string_literal: true

require 'spec_helper'

describe 'sitemaps', type: :request do
  it 'renders xml' do
    get sitemap_path(format: :xml)

    expect(response).to be_successful
  end
end
