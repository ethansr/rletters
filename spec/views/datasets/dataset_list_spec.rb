# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "datasets/dataset_list" do
  
  fixtures :datasets, :users, :dataset_entries
  login_user(:john)
  
  before(:each) do
    assign(:datasets, users(:john).datasets)
  end

  it 'lists the dataset' do
    render
    rendered.should contain("Test Dataset 10")
  end
  
  it 'lists pending analysis tasks' do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one), :job_type => 'Base' })
    task.save
    render
    
    rendered.should have_selector("li[data-theme=e]", :content => 'You have one analysis task pending...')
  end
  
  it 'does not list completed analysis tasks' do
    task = AnalysisTask.new({ :name => 'test', :dataset => datasets(:one), :job_type => 'Base' })
    task.finished_at = Time.zone.now
    task.save
    render
    
    rendered.should_not have_selector("li[data-theme=e]")
  end
  
end
