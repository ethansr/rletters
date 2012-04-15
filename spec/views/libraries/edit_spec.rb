# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/edit" do
  
  fixtures :users, :libraries
  login_user(:john)
  
  before(:each) do
    assign(:library, users(:john).libraries[0])    
    render
  end
  
  it 'has a filled-in name field' do
    rendered.should have_selector("input[name='library[name]'][value=Harvard]")
  end
  
  it 'has a filled-in URL field' do
    rendered.should have_selector("input[name='library[url]'][value='http://sfx.hul.harvard.edu/sfx_local?']")
  end
  
end
