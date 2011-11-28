# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"

require 'simplecov'
if ENV["COVERAGE"]
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
    
    coverage_dir('/test/coverage/')
  end
end

require File.expand_path('../../config/environment', __FILE__)
require 'test/unit'
require 'mocha'
require 'webmock/test_unit'
require 'rails/test_help'
require 'examples/examples'

class ActiveSupport::TestCase
  fixtures :all

  # Stub out the Solr connection with the contents of an example file
  def stub_solr_response(example)
    res = SolrExamples.load(example)
    
    # Make sure to stub everywhere that extends SolrHelpers!
    # FIXME: Can we somehow just stub the SolrHelpers method?!
    Document.stubs(:get_solr_response).returns(res)
    InfoController.stubs(:get_solr_response).returns(res)
    Jobs::CreateDataset.stubs(:get_solr_response).returns(res)
  end
end
