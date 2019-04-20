#!/bin/sh

git submodule update --remote

bundle install

bundle exec jazzy \
  --output ./ \
  --source-directory Requests/ \
  --readme Requests/README.md \
  --author 'Alex Jackson' \
  --author_url 'https://alexj.org' \
  --module 'Requests' \
  --github_url 'https://github.com/alexjohnj/Requests' \
  --theme fullwidth
