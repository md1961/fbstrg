#! /bin/sh

cp -i db/development.sqlite3 db/development.sqlite3~
bin/rails db:environment:set RAILS_ENV=development
bin/rails db:drop db:create db:migrate db:seed
