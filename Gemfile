source 'https://rubygems.org'

ruby '2.5.1'

gem 'rails', github: "rails/rails", branch: "6-0-stable"
gem 'sass-rails'

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

group :development, :test do
  gem 'dotenv-rails'
end

group :production do
  # SendGrid, Heroku addon for sending emails
  gem 'sendgrid-ruby'
  
  gem 'uglifier'
end
