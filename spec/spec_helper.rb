# -*- encoding : utf-8 -*-
require 'rubygems'
require 'spork'

Spork.prefork do
  # Standard setup for RSpec
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'webmock/rspec'
  
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  
  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.infer_base_class_for_anonymous_controllers = true
    
    config.before(:all) do
      # Disable net connections outbound
      WebMock.enable!
      WebMock.disable_net_connect!
      
      # Speed up testing by deferring garbage collection
      DeferredGarbageCollection.start
    end
    config.after(:all) do
      DeferredGarbageCollection.reconsider
    end

    # Reset the locale and timezone to defaults on each new test
    config.before(:each) do
      I18n.locale = I18n.default_locale
      Time.zone = 'Eastern Time (US & Canada)'
    end

    # Add a helper for logging in (and out!) a user
    config.extend UserLoginHelper
  
    # Skip some tests on JRuby
    if RUBY_PLATFORM == "java"
      config.filter_run_excluding :jruby => false
    end
  end
end

Spork.each_run do
  # For the moment, nothing to do here.  If we start using FactoryGirl
  # or whatnot, you want to reload it here.
end
