require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:john)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_select 'h3', "Log in to #{APP_CONFIG['app_name']}"
  end

  # The actual POST action which creates a new user
  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => { :name => 'New User Test', :email => 'new@user.com', :identifier => 'https://newuser.com' }
    end

    assert_redirected_to users_path
    assert_not_nil session[:user]
  end

  # Attempting to POST an invalid user should make the form
  # appear, with errors
  test "should not create invalid user" do
    assert_no_difference('User.count') do
      post :create, :user => { :name => 'New User Test', :email => 'this isabademail', :identifier => 'notaurl' }
    end

    assert_response :success
    assert_select 'form' do
      # This is the list of errors
      assert_select 'ul'
    end
  end

  # You shouldn't be able to load the RPX page without posting the
  # RPX data blob to it
  test "should not be able to load RPX page" do
    assert_raise(RPXNow::ApiError) do
      get :rpx
    end
  end

  # Test that logout nulls out session[:user]
  test "should blank user on logout" do
    session[:user] = users(:john)
    get :logout
    assert_nil session[:user]
  end

  # We explicitly can't get a functional test for users#rpx, because
  # there's no way to mock the interaction with the Janrain server.
end
