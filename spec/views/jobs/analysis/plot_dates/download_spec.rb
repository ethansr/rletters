# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "plot_dates/download" do
  
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
    
    init_job_view_spec('PlotDates', 'download', 'csv')
  end
  
  after(:each) do
    @task.destroy
  end
  
  it "shows a header column" do
    render_job_view('PlotDates', 'download', 'csv')
    rendered.should contain("Year,Number of Documents")
  end
  
  it 'shows the year and count in a CSV row' do
    render_job_view('PlotDates', 'download', 'csv')
    rendered.should contain("2003,13")
  end
end
