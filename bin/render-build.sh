#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

STORAGE_DIR=/opt/render/project/.render

if [[ ! -d $STORAGE_DIR/chrome_driver ]]; then
  echo "...Downloading Chrome Driver"
  mkdir -p $STORAGE_DIR/chrome_driver
  cd $STORAGE_DIR/chrome_driver
  wget https://chromedriver.storage.googleapis.com/2.41/chromedriver_linux64.zip
  unzip chromedriver_linux64.zip
  chmod +x chromedriver
else
  echo "...Using Chrome Driver from cache"
fi