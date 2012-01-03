# -*- encoding : utf-8 -*-
require 'minitest_helper'

class CreateDatasetTest < ActiveSupport::TestCase
  fixtures :users
  
  test "should not be able to create dataset for invalid user" do
    assert_raises ActiveRecord::RecordNotFound do
      Jobs::CreateDataset.new('123123123123', 'Test Dataset', 
        '*:*', nil, 'precise').perform
    end      
  end
  
  test "should create dataset from precise_all" do
    SolrExamples.stub :dataset_precise_all
    assert_difference('users(:john).datasets.count') do
      Jobs::CreateDataset.new(users(:john).to_param, 'Test Dataset', 
        '*:*', nil, 'precise').perform
    end
  end

  test "should create dataset from precise_with_facet_koltz" do
    SolrExamples.stub :dataset_precise_with_facet_koltz
    assert_difference('users(:john).datasets.count') do
      Jobs::CreateDataset.new(users(:john).to_param, 'Test Dataset',
        '*:*', ['authors_facet:"Amanda M. Koltz"'], 'precise').perform
    end
  end
  
  test "should create dataset from search_diversity" do
    SolrExamples.stub :dataset_search_diversity
    assert_difference('users(:john).datasets.count') do
      Jobs::CreateDataset.new(users(:john).to_param, 'Test Dataset',
        'diversity', nil, 'standard').perform
    end
  end
  
  test "should create large dataset" do
    SolrExamples.stub [ :long_query_one, :long_query_two, :long_query_three ]
    assert_difference('users(:john).datasets.count') do
      Jobs::CreateDataset.new(users(:john).to_param, 'Long Dataset',
        '*:*', nil, 'precise').perform
    end
    
    dataset = users(:john).datasets.find_by_name('Long Dataset')
    refute_nil dataset
    assert_equal 2300, dataset.entries.count
  end
  
  test "should not create dataset if Solr fails" do
    SolrExamples.stub :error
    assert_no_difference('users(:john).datasets.count') do
      assert_raises StandardError do
        Jobs::CreateDataset.new(users(:john).to_param, 'Test Dataset', 
          '*:*', nil, 'precise').perform
      end
    end
  end
end
