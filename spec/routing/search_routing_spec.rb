# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchController do
    
  describe "routing" do
    it 'routes to #index' do
      get('/search').should route_to('search#index')
    end
    
    it 'routes to #advanced' do
      get('/search/advanced').should route_to('search#advanced')
    end
    
    it 'routes to #show' do
      get('/search/document/1').should route_to('search#show', :id => "1")
    end
    
    it 'routes to #show with other formats' do
      get('/search/document/1.marcxml').should route_to('search#show', :id => "1", :format => "marcxml")
    end
    
    it 'routes to #to_mendeley' do
      get('/search/document/1/mendeley').should route_to('search#to_mendeley', :id => "1")
    end
    
    it 'routes to #to_citeulike' do
      get('/search/document/1/citeulike').should route_to('search#to_citeulike', :id => "1")
    end
  end
  
end

    