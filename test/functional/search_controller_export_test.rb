# -*- encoding : utf-8 -*-
require 'test_helper'

class SearchControllerExportTest < ActionController::TestCase
  tests SearchController
  
  test "should get export - marc" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'marc' }
    assert_response :success
    assert_equal 'application/marc', @response.content_type
  end
  
  test "should get export - json" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'json' }
    assert_response :success
    assert_equal 'application/json', @response.content_type
  end

  test "should get export - marcxml" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'marcxml' }
    assert_response :success
    assert_equal 'application/marcxml+xml', @response.content_type
  end
  
  test "should get export - bibtex" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'bibtex' }
    assert_response :success
    assert_equal 'application/x-bibtex', @response.content_type
  end
  
  test "should get export - endnote" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'endnote' }
    assert_response :success
    assert_equal 'application/x-endnote-refer', @response.content_type
  end
  
  test "should get export - ris" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'ris' }
    assert_response :success
    assert_equal 'application/x-research-info-systems', @response.content_type
  end
  
  test "should get export - mods" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'mods' }
    assert_response :success
    assert_equal 'application/mods+xml', @response.content_type
  end
  
  test "should get export - rdf" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'rdf' }
    assert_response :success
    assert_equal 'application/rdf+xml', @response.content_type
  end
  
  test "should get export - n3" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'n3' }
    assert_response :success
    assert_equal 'text/rdf+n3', @response.content_type
  end
  
  test "should fail to export on an invalid format" do
    stub_solr_response :precise_one_doc
    get :show, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => 'csv' }
    assert_response 406
  end
end
