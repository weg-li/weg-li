# frozen_string_literal: true

xml.instruct!

xml.urlset 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd' do
  @urls.each do |url|
    xml.url do
      xml.loc url
      xml.changefreq 'always'
    end
  end
end
