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
  
  test "should create dataset (DJ)" do
    stub_solr_response :dataset_precise_all
    
    expected_job = Jobs::CreateDataset.new(users(:john).to_param,
      'Test Dataset', '*:*', nil, 'precise')
    Delayed::Job.expects(:enqueue).with(expected_job).once
    
    post :create, { :dataset => { :name => 'Test Dataset' }, 
      :q => '*:*', :fq => nil, :qt => 'precise' }
    assert_redirected_to datasets_path
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
  
  test "destroy cancel button should work" do
    Delayed::Job.expects(:enqueue).never
    delete :destroy, :id => datasets(:one).to_param, :cancel => true
    
    assert_redirected_to dataset_path(datasets(:one))
  end

  test "should destroy dataset (DJ)" do
    expected_job = Jobs::DestroyDataset.new(users(:john).to_param, datasets(:one).to_param)
    Delayed::Job.expects(:enqueue).with(expected_job).once
    
    delete :destroy, :id => datasets(:one).to_param
    assert_redirected_to datasets_path
  end
end
