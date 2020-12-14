#!/usr/bin/env bash
# exit on error
set -o errexit

sudo apt-get update && sudo apt-get install -y openalpr openalpr-daemon openalpr-utils libopenalpr-dev
bundle install
