xml.instruct!

xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
 xml.channel do
   xml.title       "weg-li Feed"
   xml.link        url_for only_path: false, controller: 'articles'
   xml.description "Updates from the weg-li blog"

   @articles.each do |article|
     xml.item do
       xml.title       article.title
       xml.description article.body
       xml.pubDate     article.created_at.rfc822
       xml.link        article_url(article)
       xml.guid        article_url(article)
     end
   end
 end
end
