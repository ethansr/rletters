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
  
  # Check the ability to get export files by URL
  test "should get export files directly by URL" do
    stub_solr_response :precise_one_doc
    get '/search/document/00972c5123877961056b21aea4177d0dc69c7318.marcxml'
    assert_response :success
    assert_equal 'application/marcxml+xml', @response.content_type
  end
end
