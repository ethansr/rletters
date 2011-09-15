require 'test_helper'

class UrlRoutingTest < ActionDispatch::IntegrationTest
  fixtures :all

  # The privacy policy has an important, static, externally-facing
  # URL, so check that it works.
  test "should get privacy (external)" do
    get "/info/privacy"
    assert_response :success
  end
end