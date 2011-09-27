# -*- encoding : utf-8 -*-
require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get index" do
    stub_solr_response(SOLR_RESPONSE_EMPTY)
    get :index
    assert_response :success
  end

  test "should set documents variable" do
    stub_solr_response(SOLR_RESPONSE_VALID)
    get :index
    assert_not_nil assigns(:documents)
    assert_equal 5, assigns(:documents).count
  end

  test "should correctly parse page, per_page in index" do
    default_sq = { :q => "*:*", :qt => "precise" }
    options = { :offset => 20, :limit => 20 }
    Document.expects(:find_all_by_solr_query).with(default_sq, options).returns([])

    get :index, { :page => "1", :per_page => "20" }
    assert_equal 0, assigns(:documents).count
  end

  test "should correctly eliminate blank params" do
    params = { :q => '', :precise => '' }
    ret = @controller.search_params_to_solr_query(params)
    assert_equal '*:*', ret[:q]
    assert_equal 'precise', ret[:qt]
  end

  test "should copy over faceted browsing paramters" do
    params = { :q => "*:*", :precise => "true", :fq => [ "authors_facet:W. Shatner", "journal_facet:Astrobiology" ] }
    ret = @controller.search_params_to_solr_query(params)
    assert_equal 'authors_facet:W. Shatner', ret[:fq][0]
    assert_equal 'journal_facet:Astrobiology', ret[:fq][1]
  end

  test "should put together empty precise search correctly" do
    params = { :q => '', :precise => 'true' }
    ret = @controller.search_params_to_solr_query(params)
    assert_equal '*:*', ret[:q]
    assert_equal 'precise', ret[:qt]
  end

  test "should copy generic precise search content correctly" do
    params = { :q => 'test', :precise => 'true' }
    ret = @controller.search_params_to_solr_query(params)
    assert_equal 'test', ret[:q]
  end

  test "should mix in verbatim search parameters correctly" do
    params = { :precise => 'true', :authors => 'W. Shatner', 
      :volume => '30', :number => '5', :pages => '300-301' }
    ret = @controller.search_params_to_solr_query(params)
    assert ret[:q].include? 'authors:(W. Shatner)'
    assert ret[:q].include? 'volume:(30)'
    assert ret[:q].include? 'number:(5)'
    assert ret[:q].include? 'pages:(300-301)'
  end

  test "should handle fuzzy params as verbatim without type set" do
    params = { :precise => 'true', :journal => 'Astrobiology',
      :title => 'Testing with Spaces', :fulltext => 'alien' }
    ret = @controller.search_params_to_solr_query(params)
    assert ret[:q].include? 'journal:(Astrobiology)'
    assert ret[:q].include? 'title:(Testing with Spaces)'
    assert ret[:q].include? 'fulltext:(alien)'
  end

  test "should handle fuzzy params with type set to verbatim" do
    params = { :precise => 'true', :journal => 'Astrobiology',
      :journal_type => 'exact', :title => 'Testing with Spaces',
      :title_type => 'exact', :fulltext => 'alien',
      :fulltext_type => 'exact' }
    ret = @controller.search_params_to_solr_query(params)
    assert ret[:q].include? 'journal:(Astrobiology)'
    assert ret[:q].include? 'title:(Testing with Spaces)'
    assert ret[:q].include? 'fulltext:(alien)'
  end

  test "should handle fuzzy params with type set to fuzzy" do
    params = { :precise => 'true', :journal => 'Astrobiology',
      :journal_type => 'fuzzy', :title => 'Testing with Spaces',
      :title_type => 'fuzzy', :fulltext => 'alien',
      :fulltext_type => 'fuzzy' }
    ret = @controller.search_params_to_solr_query(params)
    assert ret[:q].include? 'journal_search:(Astrobiology)'
    assert ret[:q].include? 'title_search:(Testing with Spaces)'
    assert ret[:q].include? 'fulltext_search:(alien)'
  end

  test "should handle only year_start" do
    params = { :precise => 'true', :year_start => '1900' }
    ret = @controller.search_params_to_solr_query(params)
    assert ret[:q].include? 'year:(1900)'
  end

  test "should handle only year_end" do
    params = { :precise => 'true', :year_end => '1900' }
    ret = @controller.search_params_to_solr_query(params)
    assert ret[:q].include? 'year:(1900)'
  end

  test "should handle year range" do
    params = { :precise => 'true', :year_start => '1900', :year_end => '1910' }
    ret = @controller.search_params_to_solr_query(params)
    assert ret[:q].include? 'year:([1900 TO 1910])'
  end

  test "should correctly copy dismax search" do
    params = { :q => 'test' }
    ret = @controller.search_params_to_solr_query(params)
    assert_equal 'test', ret[:q]
  end
end
