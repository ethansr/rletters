# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UnapiController do
    
  describe "routing" do
    it 'routes to #index' do
      get('/unapi').should route_to('unapi#index')
    end
  end
  
end
