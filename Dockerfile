FROM ruby:3.2.2-alpine

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

RUN RAILS_ENV=production SECRET_KEY_BASE=pickasecuretoken bundle exec rake assets:precompile

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
