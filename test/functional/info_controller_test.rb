# -*- encoding : utf-8 -*-
require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get faq" do
    get :faq
    assert_response :success
  end

  test "should get privacy" do
    get :privacy
    assert_response :success
  end
end

