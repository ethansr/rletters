# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "single_term_vectors/start" do
  
  include JobViewSpecHelper
  
  context "when dataset has one document" do
    before(:each) do
      doc = mock_model(Document)
      
      @dataset = mock_model(Dataset)
      @dataset.stub(:entries).and_return([ doc ])
      
      init_job_view_spec('SingleTermVectors', 'start')
    end

    it 'has a link to start the task' do
      render_job_view('SingleTermVectors', 'start')
    
      link = url_for(:controller => 'datasets', :action => 'task_start', 
        :class => 'SingleTermVectors')
      rendered.should have_selector("a[href='#{link}']")
    end
  end
  
  context "when dataset has more than one document" do
    before(:each) do
      doc = mock_model(Document)
      
      @dataset = mock_model(Dataset)
      @dataset.stub(:entries).and_return([ doc, doc ])
      
      init_job_view_spec('SingleTermVectors', 'start')
    end
    
    it 'does not have a link to start the task' do
      render_job_view('SingleTermVectors', 'start')
    
      link = url_for(:controller => 'datasets', :action => 'task_start', 
        :class => 'SingleTermVectors')
      rendered.should_not have_selector("a[href='#{link}']")
    end
  end
  
end
