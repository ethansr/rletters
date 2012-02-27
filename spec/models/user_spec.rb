# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:models' if defined?(SimpleCov) && RUBY_VERSION >= "1.9.0"

describe User do
  
  fixtures :users
  
  describe '#valid' do
    context 'when empty' do
      before(:each) do
        @user = User.new
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when no identifier is specified' do
      before(:each) do
        @user = User.new({ :name => 'John Doe', :email => 'bob@bob.com' })
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when no name is specified' do
      before(:each) do
        @user = User.new({ :email => 'bob@bob.com' })
        @user.identifier = 'https://google.com'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when no email is specified' do
      before(:each) do
        @user = User.new({ :name => 'John Doe' })
        @user.identifier = 'https://google.com'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a duplicate email is specified' do
      before(:each) do
        # This is duplicate with users(:john)
        @user = User.new({ :name => 'Email Test User', :email => 'jdoe@gmail.com' })
        @user.identifier = 'https://google.com/notduplicate'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a bad email is specified' do
      before(:each) do
        @user = User.new({ :name => 'Email Test User', :email => 'asdf-not-an-email.com' })
        @user.identifier = 'https://google.com/notduplicate'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a duplicate identifier is specified' do
      before(:each) do
        # This is duplicate with users(:john)
        @user = User.new({ :name => 'ID test user', :email => 'notduplicate@gmail.com' })
        @user.identifier = 'https://google.com/profiles/johndoe'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a non-URL identifier is specified' do
      before(:each) do
        @user = User.new({ :name => 'ID test user', :email => 'notduplicate@gmail.com' })
        @user.identifier = 'thisisnotaurl'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a non-numeric per_page is specified' do
      before(:each) do
        @user = User.new({ :name => 'New Guy', :email => 'new@guy.com', 
          :per_page => 'asdfasdfwut' })
        @user.identifier = 'https://newguy.com'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a non-integer per_page is specified' do
      before(:each) do
        @user = User.new({ :name => 'New Guy', :email => 'new@guy.com',
          :per_page => 3.1415927 })
        @user.identifier = 'https://newguy.com'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when a negative per_page is specified' do
      before(:each) do
        @user = User.new({ :name => 'New Guy', :email => 'new@guy.com',
          :per_page => -10 })
        @user.identifier = 'https://newguy.com'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when per_page is zero' do
      before(:each) do
        @user = User.new({ :name => 'New Guy', :email => 'new@guy.com',
          :per_page => 0 })
        @user.identifier = 'https://newguy.com'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when language is invalid' do
      before(:each) do
        @user = User.new({ :name => 'New Guy', :email => 'new@guy.com',
          :per_page => 10, :language => 'notalocaleCODE123' })
        @user.identifier = 'https://newguy.com'
      end
      
      it "isn't valid" do
        @user.should_not be_valid
      end
    end
    
    context 'when all attributes are set correctly' do
      before(:each) do
        @user = User.new({ :name => 'New Guy', :email => 'new@guy.com',
          :per_page => 10, :language => 'en-US', 
          :timezone => 'America/New_York', :csl_style => 'apa.csl' })
        @user.identifier = 'https://newguy.com'
      end
      
      it "is valid" do
        @user.should be_valid
      end
    end
  end
  
  describe '.find_or_initialize_with_rpx' do
    context 'when given an existing user in the database' do
      before(:each) do
        hash = {
          'name' => 'John Doe',
          'email' => 'jdoe@gmail.com',
          'identifier' => 'https://google.com/profiles/johndoe' }
        @user = User.find_or_initialize_with_rpx(hash)        
      end
      
      it 'does not create a new record' do
        @user.should_not be_new_record
      end
    end
    
    context 'when given a new user not in the database' do
      before(:each) do
        hash = {
          'name' => 'New Guy',
          'email' => 'new@guy.com',
          'identifier' => 'https://newguy.com' }
        @user = User.find_or_initialize_with_rpx(hash)
      end
      
      it 'creates a new database record' do
        @user.should be_new_record
      end
    end
  end
  
end
