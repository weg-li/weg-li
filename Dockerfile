FROM ruby:3.1.4-alpine

RUN apk add --update --no-cache \
    gcompat \
    alpine-sdk \
    imagemagick \
    nodejs \
    postgresql-client \
    postgresql-dev \
    tzdata \
    yarn \
    npm

WORKDIR /app

RUN bundle config set --global path 'vendor'

CMD ["exit 0;"]
