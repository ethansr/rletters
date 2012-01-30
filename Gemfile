source 'http://rubygems.org'

gem 'rails', '~> 3.0'
gem 'rails-i18n', '= 0.3.0'

gem 'mysql2', :platforms => [ :ruby, :mswin, :mingw ]
gem 'activerecord-jdbcmysql-adapter', :platforms => :jruby
gem 'jruby-openssl', :platforms => :jruby

gem 'capistrano'
gem 'delayed_job', '~> 3.0', '>= 3.0.1'
gem 'delayed_job_active_record'
gem 'daemons', :require => false
gem 'whenever', :require => false
gem 'airbrake'

gem 'rpx_now'
gem 'email_validator'

gem 'rubyzip'
gem 'rsolr'
gem 'marc'
gem 'rdf'
gem 'rdf-rdfxml', :platforms => [ :ruby, :mswin, :mingw ]
gem 'rdf-n3'

# citeproc-ruby relies on unicode_utils, which is Ruby 1.9-only
gem 'citeproc-ruby', :platforms => [ :ruby_19, :mingw_19 ]
gem 'bibtex-ruby', '~> 1.3', :require => 'bibtex'

gem 'haml'
gem 'haml-rails'
gem 'kramdown'

gem 'jquery-rails', '= 1.0.15'
gem 'jquery_mobile-rails', '1.0'

group :assets do
  gem 'sass-rails'
  gem 'uglifier'
  
  # Uglifier needs an ExecJS runtime, but we don't need to
  # require it everywhere.
  gem 'execjs', :require => false
  gem 'therubyracer', :require => false, 
    :platforms => [ :ruby, :mswin, :mingw ]
  gem 'therubyrhino', :require => false, 
    :platforms => :jruby
end

group :test, :development do
  gem 'rspec-rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'webrat'
  gem 'webmock'
  gem 'nokogiri'
  
  gem 'spork', '> 0.9.0rc'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'growl'
end

group :development do
  gem 'yard'
  gem 'yard-rails'
  gem 'yardstick', :require => false

  gem 'magic_encoding', :require => false

  # SimpleCov requires manual intervention, don't run it in CI. Also,
  # it only runs on Ruby 1.9.
  gem 'simplecov', '>= 0.4.0', :require => false,
    :platforms => [ :ruby_19, :mingw_19 ]
end
