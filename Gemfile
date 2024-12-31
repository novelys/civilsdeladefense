# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.0"

gem "rails", "~> 7.1.4.1"
gem "rails-i18n"

gem "sprockets-rails"

gem "cssbundling-rails", "~> 1.4" # Bundles CSS files
gem "jsbundling-rails", "~> 1.3" # Bundles JS files

gem "stimulus-rails", "~> 1.3"

# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
gem "puma"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

gem "aasm"
gem "acts_as_list"
gem "audited"
gem "awesome_nested_set"
gem "cancancan"
gem "carrierwave"
gem "counter_culture"
gem "devise", "~> 4.9.2"
gem "file_validators"
gem "fog-aws"
gem "friendly_id"
gem "groupdate"
gem "haml-rails"
gem "inherited_resources"
gem "invisible_captcha"
gem "lockbox", "~> 1.2.0"
gem "mail"
gem "mini_magick"
gem "pg_search"
gem "rack-cors"
gem "rack-rewrite"
gem "ransack"
gem "redis"
gem "caxlsx", "~> 3.4.1"
gem "sequenced"
gem "simple_form"
gem "trix-rails", require: "trix"
gem "turbo-rails"
gem "will_paginate"
gem "working_hours", "~> 1.4"
gem "sidekiq" # Async jobs
gem "rorvswild" # Errors tracking
gem "phony_rails" # Normalize phone numbers

gem "clockwork" # simulate cron on Scalingo

gem "faker", require: false

gem "omniauth_openid_connect", "~> 0.4.0"
gem "omniauth-rails_csrf_protection"

gem "prawn" # PDF generation
gem "prawn-table" # Add tables to PDFs

gem "maintenance_tasks", "~> 2.7" # Database maintenance tasks (data migrations, etc.)

gem "aws-sdk-s3", "~> 1" # AWS S3 - only used for DGA > CVD merge

group :development, :test do
  gem "brakeman", require: false
  gem "debug"

  gem "dotenv-rails"

  gem "factory_bot_rails", "~> 6.4.3"
  gem "rails-controller-testing"
  gem "rspec_junit_formatter"
  gem "rspec-rails", "~> 6.1.1"
  gem "shoulda-matchers"

  ## Linting
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rspec"
  gem "rubocop-performance"
  gem "standard"
end

group :development do
  gem "letter_opener"
  gem "annotate"

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen", ">= 3.0.5", "< 3.8"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :production do
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "~> 3.40.0"
  gem "guard-rspec"
  gem "selenium-webdriver", "~> 4.10"

  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers", "~> 5.3.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
