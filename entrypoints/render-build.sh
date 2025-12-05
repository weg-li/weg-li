#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
yarn install
NODE_OPTIONS=--openssl-legacy-provider bundle exec rake assets:precompile
