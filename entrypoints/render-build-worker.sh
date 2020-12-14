#!/usr/bin/env bash
set -euxo pipefail

apt-get update && apt-get install -y openalpr openalpr-daemon openalpr-utils libopenalpr-dev
bundle install
