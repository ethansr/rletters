# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "search/advanced.html" do
  
  before(:each) do
    render
  end
  
  describe 'guided search form' do
    it 'has a fulltext box' do
      rendered.should have_selector('input#fulltext')
    end
    
    it 'has fulltext type buttons' do
      rendered.should have_selector('input#fulltext_type_exact')
      rendered.should have_selector('input#fulltext_type_fuzzy')
    end
    
    it 'has an authors box' do      
      rendered.should have_selector('input#authors')
    end
    
    it 'has a title box' do
      rendered.should have_selector('input#title')
    end
    
    it 'has title type buttons' do
      rendered.should have_selector('input#title_type_exact')
      rendered.should have_selector('input#title_type_fuzzy')
    end
    
    it 'has a journal box' do
      rendered.should have_selector('input#journal')
    end
    
    it 'has journal type buttons' do
      rendered.should have_selector('input#journal_type_exact')
      rendered.should have_selector('input#journal_type_fuzzy')
    end
    
    it 'has a year range box' do
      rendered.should have_selector('input#year_ranges')
    end
    
    it 'has a volume box' do
      rendered.should have_selector('input#volume')
    end
    
    it 'has a number box' do
      rendered.should have_selector('input#number')
    end
    
    it 'has a pages box' do
      rendered.should have_selector('input#pages')
    end    
  end
  
  describe 'Solr search form' do
    it 'has a Solr query box' do
      rendered.should have_selector('textarea#q')
    end
  end
  
  it 'has two forms that submit to the right place' do
    rendered.should have_selector("form[action='#{search_path}'][method=get]", :count => 2)
  end
  
end
