#!/bin/sh

cd /weg-li || exit
gem install bundler
bundle install

sed -i s/localhost/"${DATABASE}"/g /weg-li/config/database.yml
/weg-li/script/setup
/weg-li/script/server