# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "plot_dates/results" do
  
  include JobViewSpecHelper
  
  before(:each) do
    @dataset = mock_model(Dataset)
    
    @task = AnalysisTask.new(:name => "Plot dataset by date", :job_type => 'PlotDates')
    @task.dataset = @dataset
    @task.result_file = Download.create_file('temp.yml') do |file|
      file.write([ [ 2003, 13 ] ].to_yaml)
      file.close
    end
    @task.save
    
    init_job_view_spec('PlotDates', 'results')
  end
  
  after(:each) do
    @task.destroy
  end
  
  it 'shows the year and count in a table row' do
    render_job_view('PlotDates', 'results')
    
    rendered.should have_selector('tbody tr') do |row|
      row.should have_selector('td', :content => '2003')
      row.should have_selector('td', :content => '13')
    end
  end
  
  it "has a link to download the results as CSV" do
    render_job_view('PlotDates', 'results')
    
    expected = url_for(:controller => 'datasets', :action => 'task_view', 
      :id => @dataset.to_param, :task_id => @task.to_param, 
      :view => 'download', :format => 'csv')
    rendered.should have_selector("a[href='#{expected}']")
  end
  
end
