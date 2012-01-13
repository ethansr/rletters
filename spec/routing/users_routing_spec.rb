# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersController do
    
  describe "routing" do
    it 'routes to #show' do
      get('/user').should route_to('users#show')
    end
    
    it 'routes to #login' do
      get('/user/login').should route_to('users#login')
    end
    
    it 'routes to #logout' do
      get('/user/logout').should route_to('users#logout')
    end
    
    it 'routes to #rpx' do
      post('/user/rpx').should route_to('users#rpx')
    end
    
    it 'routes to #create' do
      post('/user').should route_to('users#create')
    end
    
    it 'routes to #update' do
      put('/user').should route_to('users#update')
    end
  end
  
end
