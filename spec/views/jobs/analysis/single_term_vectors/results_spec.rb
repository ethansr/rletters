# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "single_term_vectors/results" do
  
  include JobViewSpecHelper
  
  before(:each) do
    @dataset = mock_model(Dataset)
    
    @task = AnalysisTask.new(:name => "Term frequency information", :job_type => 'SingleTermVectors')
    @task.dataset = @dataset
    @task.result_file = Download.create_file('temp.yml') do |file|
      file.write({ "test" => { :tf => 3, :df => 1, :tfidf => 2.5 }}.to_yaml)
      file.close
    end
    @task.save
    
    init_job_view_spec('SingleTermVectors', 'results')
  end
  
  after(:each) do
    @task.destroy
  end
  
  it 'shows the term and values in a table row' do
    render_job_view('SingleTermVectors', 'results')
    
    rendered.should have_selector('tbody tr') do |row|
      row.should have_selector('td', :content => 'test')
      row.should have_selector('td', :content => '3')
      row.should have_selector('td', :content => '1')
      row.should have_selector('td', :content => '2.5')
    end
  end
  
  it "has a link to download the results as CSV" do
    render_job_view('SingleTermVectors', 'results')
    
    expected = url_for(:controller => 'datasets', :action => 'task_view', 
      :id => @dataset.to_param, :task_id => @task.to_param, 
      :view => 'download', :format => 'csv')
    rendered.should have_selector("a[href='#{expected}']")
  end
  
end
