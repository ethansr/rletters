# -*- encoding : utf-8 -*-
require 'minitest/autorun'
require 'minitest/reporters'

MiniTest::Unit.runner = MiniTest::SuiteRunner.new
MiniTest::Unit.runner.reporters << MiniTest::Reporters::SpecReporter.new

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)

if ENV["COVERAGE"] && RUBY_VERSION >= "1.9.0"
  require 'simplecov'

  SimpleCov.start do
    add_filter '/test/'
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/vendor/bundle/'
    
    add_group 'Models', '/app/models/'
    add_group 'Controllers', '/app/controllers/'
    add_group 'Mailers', '/app/mailers/'
    add_group 'Helpers', '/app/helpers/'
    add_group 'Libraries', '/lib/'
    
    coverage_dir '/test/coverage/'
  end
end

require 'mocha'
require 'webmock/minitest'
require 'examples/examples'

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.fixture_path = Rails.root.join('test', 'fixtures')
  
  def setup
    @routes = Rails.application.routes
  end
end

ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path

