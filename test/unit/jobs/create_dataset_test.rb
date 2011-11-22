# -*- encoding : utf-8 -*-
require 'test_helper'

class CreateDatasetTest < ActionController::TestCase
  test "should create dataset from precise_all" do
    stub_solr_response :dataset_precise_all
    assert_difference('users(:john).datasets.count') do
      Jobs::CreateDataset.new(users(:john).to_param, 'Test Dataset', 
        '*:*', nil, 'precise').perform
    end
  end

  test "should create dataset from precise_with_facet_koltz" do
    stub_solr_response :dataset_precise_with_facet_koltz
    assert_difference('users(:john).datasets.count') do
      Jobs::CreateDataset.new(users(:john).to_param, 'Test Dataset',
        '*:*', ['authors_facet:"Amanda M. Koltz"'], 'precise').perform
    end
  end
  
  test "should create dataset from search_diversity" do
    stub_solr_response :dataset_search_diversity
    assert_difference('users(:john).datasets.count') do
      Jobs::CreateDataset.new(users(:john).to_param, 'Test Dataset',
        'diversity', nil, 'standard').perform
    end
  end
end
