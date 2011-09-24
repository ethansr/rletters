# -*- encoding : utf-8 -*-
require 'test_helper'

SimpleCov.command_name 'test:integration'

class UrlRoutingTest < ActionDispatch::IntegrationTest
  fixtures :all

  # The privacy policy has an important, static, externally-facing
  # URL, so check that it works.
  test "should get privacy (external)" do
    get "/info/privacy"
    assert_response :success
  end
end
