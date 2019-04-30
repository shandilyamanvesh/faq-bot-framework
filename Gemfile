source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.0'
gem 'autoprefixer-rails', '~> 9.1.0'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'devise', '~> 4.5.0'
gem 'simple_form', '~> 4.1.0'
gem 'cancancan', '~> 2.3.0'
gem 'select2-rails', '~> 4.0.3'
gem 'cocoon', '~> 1.2.12'
gem 'httparty', '~> 0.16.3'
gem 'classifier-reborn', '~> 2.2.0'
gem 'redis-rails', '~> 5.0.2'
gem 'redis', '~> 4.0.1'
gem 'chartjs-ror', '~> 3.6.2'
gem "roo", "~> 2.7.0"
gem 'kaminari', '~> 1.1.1'
gem 'oauth2', '~> 1.4.1'
gem 'attr_encrypted', '~> 3.0.0'
gem 'geocoder', '~> 1.4.9'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver', '~> 3.141.0'
end
group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring', '~> 2.0.2'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry'
  gem 'pry-rails'
end
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'bootstrap', '~> 4.2.0'
gem 'haml-rails', '~> 1.0.0'
gem 'high_voltage', '~> 3.1.0'
gem 'jquery-rails', '~> 4.3.3'
gem 'mysql2', '~> 0.4.10'
group :development do
  gem 'better_errors'
  gem 'html2haml', '~> 2.2.0'
  gem 'rails_layout', '~> 1.0.42'
  gem 'spring-commands-rspec', '~> 1.0.4'
end
group :development, :test do
  gem 'factory_bot_rails', '~> 4.11.1'
  gem 'faker', '~> 1.9.1'
  gem 'rspec-rails', '~> 3.8.1'
end
group :test do
  gem 'database_cleaner', '~> 1.7.0'
  gem 'launchy', '~> 2.4.3'
end
