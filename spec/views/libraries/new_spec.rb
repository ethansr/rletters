# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/new" do
  
  fixtures :users
  login_user(:john)
  
  before(:each) do
    assign(:library, users(:john).libraries.build)    
    render
  end
  
  it 'has a form field for name' do
    rendered.should have_selector("input[name='library[name]']")
  end
  
  it 'has a form field for URL' do
    rendered.should have_selector("input[name='library[url]']")
  end
  
end
