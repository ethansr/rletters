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

  #test "should create user" do
  #  assert_difference('User.count') do
  #    post :create, user: @user.attributes
  #  end

  #  assert_redirected_to user_path(assigns(:user))
  #end
end
