# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "plot_dates/start.html" do
  
  include JobViewSpecHelper
  
  before(:each) do
    init_job_view_spec('PlotDates', 'start')
  end
  
  it 'has a link to start the task' do
    render_job_view('PlotDates', 'start')
    
    link = url_for(:controller => 'datasets', :action => 'task_start', 
      :class => 'PlotDates')
      
    rendered.should have_selector("a[href='#{link}']")
  end
  
end
