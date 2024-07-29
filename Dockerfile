FROM ruby:3.2.5-alpine

RUN apk add --update --no-cache \
  gcompat \
  alpine-sdk \
  imagemagick \
  nodejs \
  postgresql-client \
  postgresql-dev \
  tzdata \
  yarn

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle check || bundle install

COPY package.json yarn.lock ./

RUN yarn install --check-files

COPY . ./

RUN NODE_OPTIONS=--openssl-legacy-provider RAILS_ENV=production SECRET_KEY_BASE=6254271520a1865fabd321490051fb35e5ab0591ee99dd1f8e0f5dc1719e45cbf328d43bfd47e5829e0172556fa5868f7ce7dbe08bb008772ef07bf11a6c762b bundle exec rake assets:precompile

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
