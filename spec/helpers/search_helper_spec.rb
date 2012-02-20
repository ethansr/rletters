# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchHelper do

  #describe '#num_results_string' do
  #end
  
  #describe '#page_link' do
  #end
  
  #describe '#render_pagination' do
  #end
  
  #describe '#facet_link' do
  #end
  
  #describe '#list_links_for_facet' do
  #end
  
  describe '#facet_link_list' do
    context 'when no facets present' do
      before(:each) do
        Document.stub(:facets).and_return(nil)
      end
      
      it "returns an empty string" do
        helper.facet_link_list.should eq('')
      end
    end
  end
  
  #describe '#document_bibliography_entry' do
  #end
  
end
