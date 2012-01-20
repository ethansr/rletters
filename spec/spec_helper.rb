# -*- encoding : utf-8 -*-

# Standard setup for RSpec
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'webmock/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = true
  
  # Speed up testing by deferring garbage collection
  config.before(:all) do
    DeferredGarbageCollection.start
  end
  config.after(:all) do
    DeferredGarbageCollection.reconsider
  end
  
  # Skip some tests on Ruby 1.9
  if RUBY_VERSION < "1.9.0"
    config.filter_run_excluding :ruby19 => true
  end
  # Skip some tests on JRuby
  if RUBY_PLATFORM == "java"
    config.filter_run_excluding :jruby => false
  end
end
