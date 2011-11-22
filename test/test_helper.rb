# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"

require 'simplecov'
if ENV["COVERAGE"]
  SimpleCov.start 'rails' do
    coverage_dir('test/coverage')
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
    Jobs::CreateDataset.stubs(:get_solr_response).returns(res)
  end
end
