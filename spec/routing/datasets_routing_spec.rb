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
    
    it 'routes to #start_job' do
      get('/datasets/1/start_Task').should route_to('datasets#start_job', :id => '1', :job_name => 'start_Task')
    end
    
    it "doesn't route invalid job names" do
      get('/datasets/1/start_asdf').should_not be_routable
    end
  end
  
end