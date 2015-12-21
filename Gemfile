source 'https://rubygems.org'

gem 'coffee-rails', '~> 4.1.0'
gem 'foreman' # Process manager for applications with multiple components
gem 'jbuilder', '~> 2.0' # Build JSON APIs with ease.
gem 'pg'
gem 'puma' # Concurrent ruby web server
gem 'rails', '4.2.5'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'turbolinks' # Turbolinks makes following links in your web application faster.
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets


#---------------------------------------------------------------------------------------------------

group :development, :test do
  gem 'figaro' # Environment Management
end

#---------------------------------------------------------------------------------------------------

group :production, :staging do
  gem "rails_12factor"
end

#---------------------------------------------------------------------------------------------------

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.5'
  gem "rspec-rails", "~> 3.4"
end

#---------------------------------------------------------------------------------------------------

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
