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

  # You shouldn't be able to load the RPX page without posting the
  # RPX data blob to it
  test "should not be able to load RPX page" do
    assert_raise(RPXNow::ApiError) do
      get :rpx
    end
  end
end
