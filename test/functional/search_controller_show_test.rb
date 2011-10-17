# -*- encoding : utf-8 -*-
require 'test_helper'

# Tests for SearchController#show
class SearchControllerAdvancedTest < ActionController::TestCase
  tests SearchController
  
  test "should render show-document page" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select 'li', 'Document details'
    assert_select 'ul li:nth-child(2) h3', 'How Reliable are the Methods for Estimating Repertoire Size?'
  end
  
  test "should have DOI link" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_response :success
    assert_not_nil assigns(:document)
    assert_select 'ul[data-inset=true]' do
      assert_select 'li' do
        assert_select "a[href='http://dx.doi.org/10.1111/j.1439-0310.2008.01576.x']"
      end
    end
  end
  
  test "should have redirect links" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    unless APP_CONFIG['mendeley_key'].blank?
      assert_select "ul[data-inset=true] li:nth-last-child(2)" do
        assert_select "a[href='#{mendeley_redirect_path(:id => '00972c5123877961056b21aea4177d0dc69c7318')}']"
      end
    end
    assert_select "ul[data-inset=true] li:nth-last-child(1)" do
      assert_select "a[href='#{citeulike_redirect_path(:id => '00972c5123877961056b21aea4177d0dc69c7318')}']"
    end
  end
  
  test "should have unAPI link in the page" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_select "link[href='#{unapi_url}'][rel=unapi-server][type=application/xml]"
  end
  
  test "should have some element with class unapi-id" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318' }
    assert_select ".unapi-id"
  end
end
