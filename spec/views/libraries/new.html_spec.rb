# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/new.html" do
  
  fixtures :users
  
  before(:each) do
    @user = users(:john)
    session[:user_id] = users(:john).to_param
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