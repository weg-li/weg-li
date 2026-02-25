#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
yarn install
NODE_OPTIONS=--openssl-legacy-provider bundle exec rails assets:precompile

test -f public/assets/.manifest.json
grep -q '"application.css"' public/assets/.manifest.json
