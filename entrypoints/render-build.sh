#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
yarn install
RAILS_ENV=production NODE_ENV=production SECRET_KEY_BASE_DUMMY=1 NODE_OPTIONS=--openssl-legacy-provider bundle exec rails assets:precompile

test -f public/assets/.manifest.json
grep -q '"application.css"' public/assets/.manifest.json
