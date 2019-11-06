FROM ruby:2.6.4

COPY . /var/someRubyFolder

WORKDIR /var/someRubyFolder

## add dependencies for ruby app; everything with a native extension might take some time (nokogiri, ffi...) - the build is not hanging
RUN cd script
RUN gem install bundler
RUN bundle install

# change settings in database.yml to docker-compose ip of postgres
RUN sed -i s/localhost/172.28.1.2/g /var/someRubyFolder/config/database.yml

CMD /var/someRubyFolder/script/setup_and_serve.sh