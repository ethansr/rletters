# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Library do
  
  fixtures :users
  
  describe '#valid?' do
    context 'when empty' do
      before(:each) do
        @library = Library.new
      end
      
      it "isn't valid" do
        @library.should_not be_valid
      end
    end
    
    context 'when no name spcified' do
      before(:each) do
        @library = Library.new({ :url => "http://google.com/" })
        @library.user = users(:john)
      end
      
      it "isn't valid" do
        @library.should_not be_valid
      end
    end
    
    context 'when no user specified' do
      before(:each) do
        @library = Library.new({ :name => "Google", :url => "http://google.com/" })
      end
      
      it "isn't valid" do
        @library.should_not be_valid
      end
    end
    
    context 'when no URL specified' do
      before(:each) do
        @library = Library.new({ :name => "Google" })
        @library.user = users(:john)
      end
      
      it "isn't valid" do
        @library.should_not be_valid
      end
    end
    
    context 'with a complete URL' do
      before(:each) do
        @library = Library.new({ :name => "Google", :url => "http://google.com/wut?" })
        @library.user = users(:john)
      end
      
      it "is valid" do
        @library.should be_valid
      end
    end
  end
  
  describe "URL parsing" do
    context 'when given a URL without protocol' do
      before(:each) do
        @library = Library.new({ :name => "Google", :url => "google.com/wut?" })
        @library.user = users(:john)
      end
      
      it "is valid" do
        @library.should be_valid
      end
      
      it "adds the protocol" do
        @library.valid?
        @library.url.should eq("http://google.com/wut?")
      end
    end
    
    context 'when given a URL with no trailing question mark' do
      before(:each) do
        @library = library = Library.new({ :name => "Google", :url => "http://google.com" })
        @library.user = users(:john)
      end
      
      it "is valid" do
        @library.should be_valid
      end
      
      it "adds the question mark" do
        @library.valid?
        @library.url.should eq("http://google.com?")
      end
    end
  end
  
end

