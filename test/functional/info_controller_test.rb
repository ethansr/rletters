# -*- encoding : utf-8 -*-
require 'minitest_helper'

class InfoControllerTest < ActionController::TestCase
  tests InfoController
  
  test "should get index" do
    SolrExamples.stub :precise_one_doc
    get :index
    assert_response :success
  end
  
  test "should not fail to get index if Solr returns error" do
    SolrExamples.stub :error
    get :index
    assert_response :success
  end

  test "should get faq" do
    get :faq
    assert_response :success
  end

  test "should get privacy" do
    get :privacy
    assert_response :success
  end
end

