# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "datasets/show.html" do
  
  fixtures :users, :datasets, :dataset_entries
  
  before(:each) do
    @user = users(:john)
    session[:user_id] = users(:john).to_param
    assign(:dataset, datasets(:one))
    
    params[:id] = datasets(:one).to_param
  end
  
  it 'shows the number of dataset entries' do
    render
    rendered.should contain('Number of documents: 10')
  end
  
  it 'shows pending analysis tasks' do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one) })
    task.save
    render
    
    rendered.should have_selector("li[data-theme=e]", :content => '1 analysis task pending for this dataset...')
  end
  
  it 'shows completed analysis tasks' do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one) })
    task.finished_at = Time.zone.now
    task.save
    render
    
    rendered.should have_selector("a[href='#{download_dataset_path(datasets(:one), :task_id => task.to_param)}']")
    rendered.should have_selector("h3", :content => "“test” Complete")
  end
  
end
