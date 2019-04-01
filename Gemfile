source 'https://rubygems.org'
ruby '>= 2.4'

gem 'rails', github: "rails/rails", branch: "5-2-stable"
gem 'sassc-rails'

# template engine: slim
gem 'slim'

gem 'puma'
gem 'sidekiq'
gem 'httparty'
gem 'redis'
gem 'redcarpet'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring'
end

group :test do
  gem 'rspec'
end

# release specific
gem 'sendgrid-ruby' # SendGrid, Heroku addon for email sending
gem 'dotenv-rails', group: [:development, :test]
