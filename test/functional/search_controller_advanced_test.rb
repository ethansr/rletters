# -*- encoding : utf-8 -*-
require 'test_helper'

# Tests for SearchController#advanced
class SearchControllerAdvancedTest < ActionController::TestCase
  tests SearchController
  
  test "should get advanced search page" do
    get :advanced
    assert_response :success    
  end
  
  test "should have all correct input boxes" do
    get :advanced
    assert_select 'input#fulltext'
    assert_select 'input#fulltext_type_exact'
    assert_select 'input#fulltext_type_fuzzy'
    assert_select 'input#authors'
    assert_select 'input#title'
    assert_select 'input#title_type_exact'
    assert_select 'input#title_type_fuzzy'
    assert_select 'input#journal'
    assert_select 'input#journal_type_exact'
    assert_select 'input#journal_type_fuzzy'
    assert_select 'input#year_start'
    assert_select 'input#year_end'
    assert_select 'input#volume'
    assert_select 'input#number'
    assert_select 'input#pages'
  end
  
  test "should have solr input box" do
    get :advanced
    assert_select 'textarea#q'
  end
  
  test "forms should submit to the right place" do
    get :advanced
    assert_select "form[action='#{search_path}'][method=get]", 2
  end
end