FROM ruby:2.6.6-alpine

RUN apk add --no-cache \
    alpine-sdk \
    imagemagick \
    nodejs \
    postgresql-client \
    postgresql-dev \
    tzdata \
    yarn

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install -j2
RUN yarn install

COPY . /app

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
