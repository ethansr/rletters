# -*- encoding : utf-8 -*-
require 'test_helper'

class LibrariesControllerTest < ActionController::TestCase
  setup do
    session[:user_id] = users(:john).to_param
    @harvard = users(:john).libraries[0]
  end
  
  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "should get library in index (with links)" do
    get :index
    assert_select 'li' do
      assert_select "a[href='#{edit_user_library_path(@harvard)}']", 'Harvard'
      assert_select "a[href='#{delete_user_library_path(@harvard)}']"
    end
  end
  
  test "should get add-library link" do
    get :index
    assert_select "li a[href='#{new_user_library_path}']"
  end
  
  test "should get query-library link" do
    get :index
    assert_select "li a[href='#{query_user_libraries_path}']"
  end
  
  test "should get the new library form" do
    get :new
    assert_response :success
  end
  
  test "new library form should have fields for name and url" do
    get :new
    assert_select "input[name='library[name]']"
    assert_select "input[name='library[url]']"
  end
  
  test "should get edit library form" do
    get :edit, :id => @harvard.to_param
    assert_response :success
  end
  
  test "edit library form should get library data" do
    get :edit, :id => @harvard.to_param
    assert_select "input[name='library[name]'][value=Harvard]"
    assert_select "input[name='library[url]'][value='http://sfx.hul.harvard.edu/sfx_local?']"
  end
  
  test "should get delete form" do
    get :delete, :id => @harvard.to_param
    assert_response :success
  end
  
  test "should create library" do
    assert_difference('users(:john).libraries.count') do
      post :create, :library => @harvard.attributes
    end
    
    assert_redirected_to user_path
  end
  
  test "should update library" do
    put :update, :id => @harvard.to_param, :library => @harvard.attributes
    
    assert_redirected_to user_path
  end
  
  test "cancel should prevent library from being destroyed" do
    assert_no_difference('users(:john).libraries.count') do
      delete :destroy, :id => @harvard.to_param, :cancel => true
    end
    
    assert_redirected_to user_path
  end
  
  test "should destroy library" do
    assert_difference('users(:john).libraries.count', -1) do
      delete :destroy, :id => @harvard.to_param
    end
    
    assert_redirected_to user_path
  end
  
  test "query page with empty response" do
    stub_request(:get, /worldcatlibraries.org\/registry\/lookup.*/).to_return(ResponseExamples.load(:worldcat_response_empty))
    get :query
    assert_select 'form', 0
  end
  
  test "query page wth non-empty response" do
    stub_request(:get, /worldcatlibraries.org\/registry\/lookup.*/).to_return(ResponseExamples.load(:worldcat_response_nd))
    get :query
    assert_select 'form' do
      assert_select "input[value='University of Notre Dame']"
      assert_select "input[value='http://findtext.library.nd.edu:8889/ndu_local?']"
    end
  end
end
