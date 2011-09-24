# -*- encoding : utf-8 -*-
require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end

  test "should redirect to users if not logged in" do
    session[:user] = nil
    get :index
    assert_redirected_to :controller => 'users', :action => 'index'
  end

  test "should get index" do
    session[:user] = @user
    get :index
    assert_response :success
    assert_not_nil assigns(:datasets)
  end

  # test "should create dataset" do
  #   assert_difference('Dataset.count') do
  #     post :create, :dataset => @dataset.attributes
  #   end

  #   assert_redirected_to dataset_path(assigns(:dataset))
  # end

  # test "should show dataset" do
  #   get :show, :id => @dataset.to_param
  #   assert_response :success
  # end

  # test "should destroy dataset" do
  #   assert_difference('Dataset.count', -1) do
  #     delete :destroy, :id => @dataset.to_param
  #   end

  #   assert_redirected_to datasets_path
  # end
end
