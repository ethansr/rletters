# -*- encoding : utf-8 -*-
require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
    session[:user_id] = @user.to_param
  end

  test "should redirect to users if not logged in" do
    session[:user_id] = nil
    get :index
    assert_redirected_to user_path
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:datasets)
  end
  
  test "index should list the one dataset" do
    get :index
    assert_select 'ul li a', "Test Dataset\n10"
  end
  
  test "should get the new dataset form" do
    get :new
    assert_response :success
  end
  
  test "new form should have field for name, solr query" do
    get :new, { :q => '*:*', :fq => nil, :qt => 'precise' }
    assert_select "input[name='dataset[name]']"
    assert_select "input[name=q][value='*:*']"
    assert_select "input[name='fq[]']", 0
    assert_select "input[name=qt][value=precise]"
  end
    
  test "should show dataset" do
    get :show, :id => datasets(:one).to_param
    assert_response :success
  end
  
  test "should show correct number of entries" do
    get :show, :id => datasets(:one).to_param
    assert_select "ul li p:first-of-type", 'Number of documents: 10'
  end
  
  test "should get delete form" do
    get :delete, :id => datasets(:one).to_param
    assert_response :success
  end

  test "should destroy dataset" do
    assert_difference('users(:john).datasets.count', -1) do
      delete :destroy, :id => datasets(:one).to_param
    end

    assert_redirected_to datasets_path
  end
end
