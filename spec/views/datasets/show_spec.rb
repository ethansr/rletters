# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "datasets/show" do
  
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
  
  it 'shows the create-task markup' do
    render
    rendered.should contain('Export dataset as citations')
  end
  
  it "has a reference somewhere to the task list" do
    # Need to render the layout in order to get the page-JS
    render :template => 'datasets/show', :layout => 'layouts/application'
    rendered.should include(task_list_dataset_path(datasets(:one)))
  end
  
end
