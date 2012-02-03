# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:views' if ENV["COVERAGE"] && RUBY_VERSION >= "1.9.0"

describe "search/index.html" do
  
  fixtures :users
  
  def do_solr_query(q = nil, fq = nil, precise = false, other_params = {})
    assign(:page, 0)
    assign(:per_page, 10)
    
    params[:q] = q
    params[:fq] = fq
    params[:precise] = precise
    params.merge!(other_params)
    
    solr_query = SearchController.new.send(:search_params_to_solr_query, params)
    assign(:solr_q, solr_query[:q])
    assign(:solr_qt, solr_query[:qt])
    assign(:solr_fq, solr_query[:fq])
        
    assign(:documents, Document.find_all_by_solr_query(solr_query))
  end
  
  context 'when no search is performed' do
    before(:each) do
      Examples.stub_with(/localhost/, :precise_all_docs)
      do_solr_query
    end
    
    context 'when not logged in' do
      before(:each) do
        render
      end
      
      it 'displays the number of documents in the database' do
        rendered.should have_selector('li', :content => '10 articles in database')
      end

      it 'displays the details of a document' do
        rendered.should have_selector('h3', :content => 'Parental and Mating Effort: Is There Necessarily a Trade-Off?')
        rendered.should contain('Kelly A. Stiver, Suzanne H. Alonzo')
        rendered.should contain("Ethology, Vol. 115, (2009), pp. 1101-1126")
      end
      
      it 'shows the login prompt' do
        rendered.should have_selector('li[data-theme=e]', :content => 'Log in to analyze results!')
      end
      
      it 'shows the advanced search link' do
        rendered.should have_selector('li', :content => 'Advanced search')
        rendered.should have_selector("a[href='#{search_advanced_path}']")
      end
      
      it 'shows author facets' do
        rendered.should have_selector('li', :content => 'Amanda M. Koltz1') do |items|
          items[0].should have_selector("a[href='#{search_path(:fq => [ 'authors_facet:"Amanda M. Koltz"' ])}']")
          items[0].should have_selector('span.ui-li-count', :content => '1')
        end
      end
      
      it 'shows journal facets' do
        rendered.should have_selector('li', :content => 'Ethology10') do |items|
          items[0].should have_selector("a[href='#{search_path(:fq => [ 'journal_facet:"Ethology"' ])}']")
          items[0].should have_selector('span.ui-li-count', :content => '10')
        end
      end
      
      it 'shows year facets' do
        rendered.should have_selector('li', :content => '1990–19991') do |items|
          items[0].should have_selector("a[href='#{search_path(:fq => [ 'year:[1990 TO 1999]' ])}']")
          items[0].should have_selector('span.ui-li-count', :content => '1')
        end
      end
    end
    
    context 'when logged in' do
      before(:each) do
        @user = users(:john)
        session[:user_id] = users(:john).to_param
        render
      end
      
      it 'uses CSL styles when needed' do
        rendered.should contain("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. Ethology 114 (6): 1227-1238.")
      end
      
      it 'shows the create dataset prompt' do
        rendered.should have_selector('li', :content => 'Create dataset from search')
        rendered.should have_selector("a[href='#{new_dataset_path(:q => '*:*', :qt => 'precise', :fq => nil)}']")
      end
    end
  end
  
  context 'when a search with no results is performed' do
    before(:each) do
      Examples.stub_with(/localhost/, :standard_empty_search)
      do_solr_query('shatner')
      render      
    end
    
    it 'displays that no articles are found' do
      rendered.should contain('no articles found')
    end
    
    it 'puts the search text in the search box' do
      rendered.should have_selector('input[value=shatner]')
    end
  end
  
  context 'when an advanced search is performed' do
    before(:each) do
      Examples.stub_with(/localhost/, :precise_year_2009)
      do_solr_query(nil, nil, true, :year => 2009)
      render
    end
    
    it 'displays the advanced search placeholder in the search box' do
      rendered.should have_selector("input[value='(advanced search)']")
    end
  end
  
  describe 'year facet parsing' do
    context 'when parsing 2010-*' do
      before(:each) do
        Examples.stub_with(/localhost/, :precise_all_docs)
        do_solr_query
        render
      end
      
      it 'parses this facet correctly' do
        rendered.should have_selector('li', :content => '2010 and later2') do |items|
          items[0].should have_selector("a[href='#{search_path(:fq => [ 'year:[2010 TO *]' ])}']")
          items[0].should have_selector('span.ui-li-count', :content => '2')
        end
      end
    end
    
    context 'when parsing *-1790' do
      before(:each) do
        Examples.stub_with(/localhost/, :precise_old_docs)
        do_solr_query
        render
      end
      
      it 'parses this facet correctly' do
        rendered.should have_selector('li', :content => 'Before 18001') do |items|
          items[0].should have_selector("a[href='#{search_path(:fq => [ 'year:[* TO 1799]' ])}']")
          items[0].should have_selector('span.ui-li-count', :content => '1')
        end
      end
    end
  end
  
  context 'when displaying facets' do
    before(:each) do
      Examples.stub_with(/localhost/, :precise_facet_author_and_journal)
      do_solr_query(nil, [ 'authors_facet:"Amanda M. Koltz"', 'journal_facet:"Ethology"' ])
      render
    end
    
    it 'displays a remove all link' do
      rendered.should have_selector('ul.facetlist li', :content => 'Remove All') do |items|
        items[0].should have_selector("a[href='#{search_path}']")
      end
    end
    
    it 'displays a specific remove-facet link' do
      rendered.should have_selector('ul.facetlist li', :content => 'Authors: Amanda M. Koltz') do |items|
        items[0].should have_selector("a[href='#{search_path(:fq => [ 'journal_facet:"Ethology"' ])}']")
      end
    end
  end
  
end
