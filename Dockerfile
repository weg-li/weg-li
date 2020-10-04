FROM ruby:2.7.2-alpine

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

RUN bundle install --jobs=3 --retry=2 --quiet
RUN yarn install

COPY . /app

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
