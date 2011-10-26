# -*- encoding : utf-8 -*-
require 'test_helper'

SimpleCov.command_name 'test:functionals'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
    session[:user_id] = nil
  end

  test "should get show (to login)" do
    get :show
    assert_redirected_to login_user_path
  end

  test "should get login" do
    get :login
    assert_response :success
    assert_select 'h3', "Log in to #{APP_CONFIG['app_name']}"
  end

  test "should create user" do
    session[:user_id] = nil
    
    assert_difference('User.count') do
      post :create, :user => { :name => 'New User Test', :email => 'new@user.com', :identifier => 'https://newuser.com', :per_page => 10, :language => 'es-MX' }
    end

    assert_redirected_to datasets_path
    assert_not_nil session[:user_id]
    assert_not_nil assigns(:user)
  end

  # Attempting to POST an invalid user should make the form
  # appear, with errors
  test "should not create invalid user" do
    assert_no_difference('User.count') do
      post :create, :user => { :name => 'New User Test', :email => 'this isabademail', :identifier => 'notaurl' }
    end

    assert_response :success
    assert_select 'form' do
      assert_select 'ul[data-theme=e]'
    end
  end
  
  # POSTing an invalid user is the only way to test the form on
  # the "new" template.
  test "should fill in the user's default language on the form (w/ country)" do
    @request.env['HTTP_ACCEPT_LANGUAGE'] = "es-mx,es;q=0.5"
    post :create, :user => { :name => 'New User Test', :email => 'this is a bad email', :identifier => 'notaurl' }
    assert_response :success
    assert_select 'select[id=user_language]' do
      assert_select 'option[value=es-MX][selected=selected]'
    end
  end
  
  test "should fill in the user's default language on the form (w/o country)" do
    @request.env['HTTP_ACCEPT_LANGUAGE'] = "es"
    post :create, :user => { :name => 'New User Test', :email => 'this is a bad email', :identifier => 'notaurl' }
    assert_response :success
    assert_select 'select[id=user_language]' do
      assert_select 'option[value=es][selected=selected]'
    end
  end

  test "should update user" do
    session[:user_id] = users(:john).to_param
    post :update, :id => users(:john), :user => { :name => 'Not Johns Name', :email => 'jdoe@gmail.com' }
    
    assert_equal 0, users(:john).errors.count
    
    users(:john).reload
    assert_equal "Not Johns Name", users(:john).name
  end

  test "should fail to invalidly update user" do
    session[:user_id] = users(:john).to_param
    post :update, :id => users(:john), :user => { :name => 'John Doe', :email => 'thisisnotan.email' }

    assert_response :success
    assert_select 'form' do
      assert_select 'li[data-theme=e]'
    end
  end

  # You shouldn't be able to load the RPX page without posting the
  # RPX data blob to it (allow real network connections here, as the
  # RPXNow gem will try to validate this out to the Janrain server and
  # fail)
  test "should not be able to load RPX page" do
    WebMock.allow_net_connect!
    
    assert_raise(RPXNow::ApiError) do
      get :rpx
    end
    
    WebMock.disable_net_connect!
  end

  test "should blank user on logout" do
    session[:user_id] = users(:john).to_param
    get :logout
    assert_nil session[:user_id]
    assert_nil assigns(:user)
  end

  test "should redirect to search on logout" do
    session[:user_id] = users(:john).to_param
    get :logout
    assert_redirected_to root_url
  end

  test "should redirect from logout if not logged in" do
    session[:user_id] = nil
    get :logout
    assert_redirected_to user_path
  end

  test "should redirect from update if not logged in" do
    session[:user_id] = nil
    get :update
    assert_redirected_to user_path
  end

  # We explicitly can't get a functional test for users#rpx, because
  # there's no way to mock the interaction with the Janrain server.
end
