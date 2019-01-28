#! /bin/sh

bin/rails db:environment:set RAILS_ENV=development
bin/rails db:drop db:create db:migrate db:seed
