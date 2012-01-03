source 'http://rubygems.org'

gem 'rails', '~> 3.0'
gem 'rails-i18n', '= 0.3.0.beta2'

gem 'mysql2', :platforms => [ :ruby, :mswin, :mingw ]
gem 'activerecord-jdbcmysql-adapter', :platforms => :jruby
gem 'jruby-openssl', :platforms => :jruby

gem 'capistrano'
gem 'delayed_job'
gem 'whenever', :require => false
gem 'airbrake'

gem 'rpx_now'

gem 'rubyzip'
gem 'rsolr'
gem 'marc'
gem 'rdf'
gem 'rdf-rdfxml', :platforms => [ :ruby, :mswin, :mingw ]
gem 'rdf-n3'

# citeproc-ruby relies on unicode_utils, which is Ruby 1.9-only
gem 'citeproc-ruby', :platforms => [ :ruby_19, :mingw_19 ]

gem 'haml'
gem 'haml-rails'
gem 'kramdown'

gem 'jquery-rails', '= 1.0.15'
gem 'jquery_mobile-rails', '1.0'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'

  gem 'uglifier'
  gem 'execjs'
  
  gem 'therubyracer', :platforms => [ :ruby, :mswin, :mingw ]
  gem 'therubyrhino', :platforms => :jruby
end

group :test do
  gem 'ffi-ncurses', :platforms => :jruby
  
  gem 'minitest', :require => false
  gem 'mini_specunit', :require => false
  gem 'minitest-reporters', :require => false
  
  gem 'mocha', :require => false
  gem 'webmock'
  gem 'nokogiri'
end

group :development do
  gem 'yard'
  gem 'yard-rails'
  gem 'yardstick'

  gem 'magic_encoding'

  # SimpleCov requires manual intervention, don't run it in CI. Also,
  # it only runs on Ruby 1.9.
  gem 'simplecov', '>= 0.4.0', :require => false,
    :platforms => [ :ruby_19, :mingw_19 ]
end
