source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8", ">= 7.0.8.4"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

gem "bootsnap", require: false

gem 'httparty'

gem 'rack-cors', require: 'rack/cors'

# Twitch-Token
gem 'omniauth'
gem 'omniauth-oauth2'
gem 'omniauth-twitch'
gem 'omniauth-rails_csrf_protection'

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'sqlite3', '~> 1.4'
  gem 'dotenv-rails'
end

group :development do

end