# -*- encoding : utf-8 -*-
require 'test_helper'

class SearchControllerIndexTest < ActionController::TestCase
  tests SearchController
  
  test "should get index" do
    stub_solr_response :standard_empty_search
    get :index
    assert_response :success
  end

  test "should set documents variable" do
    stub_solr_response :precise_all_docs
    get :index
    assert_not_nil assigns(:documents)
    assert_equal 10, assigns(:documents).count
  end

  test "should display number of documents found" do
    stub_solr_response :precise_all_docs
    get :index
    assert_select 'li', '10 articles in database'
  end

  test "should display correctly when no documents found" do
    stub_solr_response :standard_empty_search
    get :index, { :q => 'shatner' }
    assert_select 'li', 'no articles found'
  end

  test "should display search text in search box" do
    stub_solr_response :standard_empty_search
    get :index, { :q => 'shatner' }
    assert_select 'input[value=shatner]'
  end

  test "should display advanced search placeholder" do
    stub_solr_response :precise_year_2009
    get :index, { :precise => 'true', :q => 'year:2009' }
    assert_select 'input[value=(advanced search)]'
  end

  test "should display document details (default citation format)" do
    stub_solr_response :precise_all_docs
    get :index
    assert_select 'div.leftcolumn ul li:nth-of-type(3)' do
      assert_select 'h3', 'Parental and Mating Effort: Is There Necessarily a Trade-Off?'
      assert_select 'p:first-of-type', 'Kelly A. Stiver, Suzanne H. Alonzo'
      assert_select 'p:last-of-type', "Ethology, Vol. 115,\n(2009),\npp. 1101-1126"
    end
  end

  test "should display document details (chicago format)" do
    stub_solr_response :precise_all_docs
    session[:user] = users(:john)
    get :index
    assert_select 'div.leftcolumn ul li:nth-of-type(7)', "Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. Ethology 114: 1227-1238."
  end

  test "should show login prompt if not logged in" do
    stub_solr_response :standard_empty_search
    session[:user] = nil
    get :index
    assert_select 'li[data-theme=e]', 'Log in to analyze results!'
  end

  test "should show create-dataset prompt if logged in" do
    stub_solr_response :standard_empty_search
    session[:user] = users(:john)
    get :index
    assert_select 'li', 'Create dataset from search'
  end
  
  test "should show advanced search link" do
    stub_solr_response :standard_empty_search
    get :index
    assert_select 'div.rightcolumn ul li:last-of-type', 'Advanced search'    
  end

  test "should show author facets" do
    stub_solr_response :precise_all_docs
    get :index
    assert_select 'div.rightcolumn ul:nth-of-type(3) li:nth-of-type(2)', 'Amanda M. Koltz1' do
      assert_select "a[href=#{search_path(:fq => [ 'authors_facet:"Amanda M. Koltz"' ])}]"
      assert_select 'span.ui-li-count', '1'
    end
  end

  test "should show journal facets" do
    stub_solr_response :precise_all_docs
    get :index
    # We show five author facet choices, then the journal facet, which is number 6.
    assert_select 'div.rightcolumn ul:nth-of-type(3) li:nth-of-type(8)', 'Ethology10' do
      assert_select "a[href=#{search_path(:fq => [ 'journal_facet:"Ethology"' ])}]"
      assert_select 'span.ui-li-count', '10'
    end
  end

  test "should show year facets" do
    stub_solr_response :precise_all_docs
    get :index
    # We show five author facet choices, then the journal facet, then the year facets by count
    assert_select 'div.rightcolumn ul:nth-of-type(3) li:nth-of-type(12)', '1990–19991' do
      assert_select "a[href=#{search_path(:fq => [ 'year:[1990 TO 1999]' ])}]"
      assert_select 'span.ui-li-count', '1'
    end
  end
  
  test "should parse 2010-* year facet correctly" do
    stub_solr_response :precise_all_docs
    get :index
    # We show five author facet choices, then the journal facet, then the year facets by count
    assert_select 'div.rightcolumn ul:nth-of-type(3) li:nth-of-type(11)', '2010 and later2' do
      assert_select "a[href=#{search_path(:fq => [ 'year:[2010 TO *]' ])}]"
      assert_select 'span.ui-li-count', '2'
    end    
  end
  
  test "should parse *-1790 year facet correctly" do
    stub_solr_response :precise_old_docs
    get :index
    # We show five author facet choices, then the journal facet, then the year facets by count
    assert_select 'div.rightcolumn ul:nth-of-type(3) li:nth-of-type(13)', 'Before 18001' do
      assert_select "a[href=#{search_path(:fq => [ 'year:[* TO 1799]' ])}]"
      assert_select 'span.ui-li-count', '1'
    end
  end

  test "should display remove all link with facets" do
    stub_solr_response :precise_with_facet_koltz
    get :index, { :fq => [ 'authors_facet:"Amanda M. Koltz"' ] }
    assert_select 'div.rightcolumn ul:nth-of-type(3) li:nth-of-type(2)', 'Remove All' do
      assert_select "a[href=#{search_path}]"
    end
  end

  test "should display specific remove facet links" do
    stub_solr_response :precise_facet_author_and_journal
    get :index, { :fq => [ 'authors_facet:"Amanda M. Koltz"', 'journal_facet:"Ethology"' ] }
    assert_select 'div.rightcolumn ul:nth-of-type(3) li:nth-of-type(3)', 'Authors: Amanda M. Koltz' do
      assert_select "a[href=#{search_path(:fq => [ 'journal_facet:"Ethology"' ])}]"
    end
  end

  test "should correctly parse page, per_page in index" do
    default_sq = { :q => "*:*", :qt => "precise" }
    options = { :offset => 20, :limit => 20 }
    Document.expects(:find_all_by_solr_query).with(default_sq, options).returns([])

    get :index, { :page => "1", :per_page => "20" }
    assert_equal 0, assigns(:documents).count
  end
end