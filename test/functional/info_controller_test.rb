# -*- encoding : utf-8 -*-
require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  test "should get index" do
    stub_solr_response :precise_one_doc
    get :index
    assert_response :success
  end
  
  test "should not fail to get index if Solr returns error" do
    stub_solr_response :error
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

