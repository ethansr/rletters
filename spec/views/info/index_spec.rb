# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "info/index" do

  # This is a set of tests for the Markdown template handler, which has to
  # be tested in a view spec to get access to the render method.
  describe MarkdownTemplate do
    before(:each) do
      @filename = Rails.root.join('app', 'views', 'static', '_testing.markdown')
      
      File.open(@filename, 'w') do |f|
        f.write('# Testing #')
      end
    end
    
    after(:each) do
      File.delete(@filename)
    end
    
    it 'renders Markdown formatted templates' do
      render :partial => 'static/testing'
      rendered.should have_selector('h1', :content => 'Testing')
    end
  end
  
end
