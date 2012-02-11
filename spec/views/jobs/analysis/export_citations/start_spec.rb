# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "export_citations/start" do
  
  include JobViewSpecHelper
  
  before(:each) do
    init_job_view_spec('ExportCitations', 'start')
  end
  
  it 'has links to all the document formats' do
    render_job_view('ExportCitations', 'start')
    
    Document.serializers.each do |k, v|
      link = url_for(:controller => 'datasets', :action => 'task_start', 
        :class => 'ExportCitations', :job_params => { :format => k })
      
      rendered.should have_selector("a[href='#{link}']")
    end
  end
  
end
