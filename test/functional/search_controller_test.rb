require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get index" do
    stub_solr_response(SOLR_RESPONSE_EMPTY)
    get :index
    assert_response :success
  end
end
