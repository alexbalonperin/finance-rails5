source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'haml-rails', '~> 0.9.0'

gem 'font-awesome-rails', '~> 4.6.3.1'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.1.1'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'require_reloader', '~> 0.2.0'

# gem 'yahoo-finance', :github => 'herval/yahoo-finance', :branch => 'markets_improvements'
gem 'yahoo-finance', :path => '/Users/abalonperin/dev/yahoo-finance'

gem 'stock_quote', '~> 1.2.3'

gem 'roo', '~> 2.5.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'rspec-rails', '~> 3.5.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '~> 3.3.1'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 1.7.2'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Pry is a powerful alternative to the standard IRB shell for Ruby.
  # It features syntax highlighting, a flexible plugin architecture, runtime invocation and source and documentation browsing.
  #gem 'pry-rails'
  gem 'awesome_print', '~> 1.7.0', require: 'ap'
  gem 'peek', '~> 0.2.0'
  gem 'activerecord-import', '~> 0.15.0'
  gem 'pronto', '~> 0.6.0'
  gem 'pronto-rubocop', '~> 0.6.2', require: false
  gem 'pronto-flay', '~> 0.6.2', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :test do
  gem 'faker', '~> 1.6.5'
  gem 'capybara', '~> 2.7.1'
  gem 'guard-rspec', '~> 4.7.2'
  gem 'launchy', '~> 2.4.3'
  gem 'rails-controller-testing', '~> 0.1.1'
end