# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "libraries/index" do
  
  fixtures :users, :libraries
  
  before(:each) do
    @user = users(:john)
    session[:user_id] = users(:john).to_param
    assign(:libraries, users(:john).libraries)
    
    render
  end
  
  it 'has a link to edit the library' do
    rendered.should have_selector("a[href='#{edit_user_library_path(libraries(:harvard))}']", :content => 'Harvard')
  end
  
  it 'has a link to delete the library' do
    rendered.should have_selector("a[href='#{delete_user_library_path(libraries(:harvard))}']")
  end
  
  it 'has a link to add a new library' do
    rendered.should have_selector("a[href='#{new_user_library_path}']")
  end
  
  it 'has a link to query local libraries' do
    rendered.should have_selector("a[href='#{query_user_libraries_path}']")
  end
  
end
