# -*- encoding : utf-8 -*-
require 'minitest_helper'

class UnapiControllerTest < ActionController::TestCase
  tests UnapiController
  
  def get_unapi(with_id = false, format = nil)
    if with_id
      SolrExamples.stub :precise_one_doc
      get :index, { :id => '00972c5123877961056b21aea4177d0dc69c7318', :format => format }
    else
      get :index
    end
    
    unless format
      @doc = REXML::Document.new @response.body
      @formats = @doc.root.elements.to_a('format')
    end
  end
  
  test "should get the formats page" do
    get_unapi
    assert_response :success
  end
  
  test "should return formats page with application/xml" do
    get_unapi
    assert_equal 'application/xml', @response.content_type
  end
  
  test "should have formats tag as root" do
    get_unapi
    assert_equal 'formats', @doc.root.name
  end
  
  test "should have >0 formats in response" do
    get_unapi
    refute_equal 0, @formats.count
  end
  
  test "each format should have a type" do
    get_unapi
    @formats.each do |f|
      refute_nil f.attributes['type']
    end
  end
  
  test "each format should have a name" do
    get_unapi
    @formats.each do |f|
      refute_nil f.attributes['name']
    end
  end
  
  test "request for id should return application/xml" do
    get_unapi true
    assert_equal 'application/xml', @response.content_type
  end
  
  test "request for id w/o format should return 300" do
    get_unapi true
    assert_response 300
  end
  
  test "request for id w/o format should return formats" do
    get_unapi true
    refute_equal 0, @formats.count
  end

  test "each format (w/ id) should have a type" do
    get_unapi true
    @formats.each do |f|
      refute_nil f.attributes['type']
    end
  end
  
  test "each format (w/ id) should have a name" do
    get_unapi true
    @formats.each do |f|
      refute_nil f.attributes['name']
    end
  end
  
  test "request w/ bad format should return a 406" do
    get_unapi true, 'css'
    assert_response 406
  end
  
  test "request for each format should succeed" do
    get_unapi true
    @formats.each do |f|
      get_unapi true, f.attributes['name']
      
      assert_redirected_to :controller => 'search', :action => 'show', 
        :id => '00972c5123877961056b21aea4177d0dc69c7318', 
        :format => f.attributes['name'].to_s
    end
  end
  
  test "requests for good formats w/ invalid ids should return 404" do
    get_unapi true
    @formats.each do |f|
      SolrExamples.stub :precise_one_doc
      get :index, { :id => 'woobadid', :format => f.attributes['name'] }
    end
  end
end
