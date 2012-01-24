# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetsController do
  
  describe "routing" do
    it 'routes to #index' do
      get('/datasets').should route_to('datasets#index')
    end
    
    it 'routes to #show' do
      get('/datasets/1').should route_to('datasets#show', :id => '1')
    end
    
    it 'routes to #new' do
      get('/datasets/new').should route_to('datasets#new')
    end
    
    it 'routes to #delete' do
      get('/datasets/1/delete').should route_to('datasets#delete', :id => '1')
    end
    
    it 'routes to #create' do
      post('/datasets').should route_to('datasets#create')
    end
    
    it 'routes to #destroy' do
      delete('/datasets/1').should route_to('datasets#destroy', :id => '1')
    end
    
    it "doesn't route to #update" do
      put('/datasets/1').should_not be_routable
    end
    
    it "doesn't route to #edit" do
      get('/datasets/1/edit').should_not be_routable
    end
    
    it 'routes to #task_start' do
      get('/datasets/1/task/Task/start').should route_to('datasets#task_start', :id => '1', :class => 'Task')
    end
    
    it "doesn't route invalid classes to start" do
      get('/datasets/1/task/asdf/start').should_not be_routable
    end
    
    it 'routes to #task_view' do
      get('/datasets/1/task/2/view/show').should route_to('datasets#task_view', :id => '1', :task_id => '2', :view => 'show')
    end
    
    it "doesn't route invalid task IDs to show" do
      get('/datasets/1/task/NotID/view/show').should_not be_routable
    end
    
    it "routes to #task_destroy" do
      get('/datasets/1/task/2/destroy').should route_to('datasets#task_destroy', :id => '1', :task_id => '2')
    end
    
    it "doesn't route invalid task IDs to destroy" do
      get('/datasets/1/task/wut/destroy').should_not be_routable
    end
    
    it "routes to #task_download" do
      get('/datasets/1/task/2/download').should route_to('datasets#task_download', :id => '1', :task_id => '2')
    end
    
    it "doesn't route invalid task IDs to download" do
      get('/datasets/1/task/wut/download').should_not be_routable
    end
  end
  
end
