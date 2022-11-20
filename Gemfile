source 'https://rubygems.org'

ruby '3.0.4'

gem 'httparty'
gem 'puma'
gem 'rails', '~> 6.1'
gem 'redis'
gem 'redcarpet'
gem 'sidekiq'
gem 'slim'
gem 'webpacker'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring'
end

group :test do
  gem 'rspec'
end

group :development, :test do
  gem 'dotenv-rails'
end

group :production do
  gem 'sendgrid-ruby' # SendGrid, Heroku addon for sending emails
end
