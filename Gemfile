# Load the application config, as we're doing some loading of gems based on
# whether or not you specify your secret API keys
APP_CONFIG = YAML.load_file(File.join(Dir.pwd, 'config', 'app_config.yml'))["all_environments"] unless ENV['TRAVIS']

source 'http://rubygems.org'

gem 'rails', '~> 3.1.3'
gem 'mysql2'

gem 'capistrano'
gem 'delayed_job'
gem 'whenever', :require => false

gem 'rails-i18n'

gem 'rpx_now'

gem 'rsolr'
gem 'citeproc-ruby'
gem 'marc'
gem 'rdf'
gem 'rdf-rdfxml'
gem 'rdf-n3'

gem 'haml'
gem 'haml-rails'
gem 'maruku'

group :assets do
  gem 'sass-rails', "~> 3.1.5"
  gem 'coffee-rails', "~> 3.1.1"

  gem 'uglifier'
  gem 'execjs'
  gem 'therubyracer'
end

gem 'jquery-rails', '= 1.0.15'
gem 'jquery_mobile-rails', '1.0'

group :test do
  gem 'test-unit', :require => false
  gem 'mocha', :require => false
  gem 'webmock'
  gem 'sqlite3'
  gem 'simplecov', '>= 0.4.0', :require => false
  gem 'nokogiri'
end

gem 'yard'
gem 'yard-rails'
gem 'yardstick'

unless ENV['TRAVIS'] || APP_CONFIG['airbrake_key'].nil? || APP_CONFIG['airbrake_key'].empty?
  gem 'airbrake'
end

gem 'magic_encoding'

