# -*- encoding : utf-8 -*-
require 'spec_helper'

describe LibrariesController do
  
  fixtures :libraries, :users
  
  before(:each) do
    @user = users(:john)
    session[:user_id] = users(:john).to_param
    @harvard = users(:john).libraries[0]
  end
  
  describe '#index' do
    it 'loads successfully' do
      get :index
      response.should be_success
    end    
  end
  
  describe '#new' do
    it 'loads successfully' do
      get :new
      response.should be_success
    end
  end
  
  describe '#create' do
    context 'when library is valid' do
      it 'creates a library' do
        expect {
          post :create, :library => @harvard.attributes
        }.to change{users(:john).libraries.count}.by(1)
      end
      
      it 'redirects to the user page' do
        post :create, :library => @harvard.attributes
        response.should redirect_to(user_path)
      end
    end
    
    context 'when library is invalid' do
      it "doesn't create a library" do
        expect {
          post :create, :library => { :name => 'bad', :url => 'not##::aurl.asdfwut' }
        }.to_not change{users(:john).libraries.count}
      end
      
      it "renders the new form" do
        post :create, :library => { :name => 'bad', :url => 'not##::aurl.asdfwut' }
        response.should render_template(:new)
      end
    end
  end
  
  describe '#edit' do
    it 'loads successfully' do
      get :edit, :id => @harvard.to_param
      response.should be_success
    end
  end
  
  describe '#update' do
    context 'when library is valid' do
      it 'edits the library' do
        attrs = @harvard.attributes
        attrs[:name] = 'Woo'
        
        put :update, :id => @harvard.to_param, :library => attrs
        
        users(:john).libraries(true)
        users(:john).libraries[0].name.should eq('Woo')
      end
      
      it 'redirects to the user page' do
        put :update, :id => @harvard.to_param, :library => @harvard.attributes
        response.should redirect_to(user_path)
      end
    end
    
    context 'when library is invalid' do
      it "doesn't edit the library" do
        put :update, :id => @harvard.to_param, :library => { :user => users(:john).to_param,
          :name => 'Woo', :url => 'not##::aurl.asdfwut' }
        
        users(:john).libraries(true)
        users(:john).libraries[0].name.should eq('Harvard')
      end
      
      it 'renders the edit form' do
        put :update, :id => @harvard.to_param, :library => { :user => users(:john).to_param,
          :name => 'Woo', :url => 'not##::aurl.asdfwut' }
        response.should render_template(:edit)
      end
    end
  end
  
  describe '#delete' do
    it 'loads successfully' do
      get :delete, :id => @harvard.to_param
      response.should be_success
    end
  end
  
  describe '#destroy' do
    context 'when cancel is pressed' do
      it 'does not delete the library' do
        expect {
          delete :destroy, :id => @harvard.to_param, :cancel => true
        }.to_not change{users(:john).libraries.count}
      end
      
      it 'redirects to the user page' do
        delete :destroy, :id => @harvard.to_param, :cancel => true
        response.should redirect_to(user_path)
      end
    end
    
    context 'when cancel is not pressed' do
      it 'deletes the library' do
        expect {
          delete :destroy, :id => @harvard.to_param
        }.to change{users(:john).libraries.count}.by(-1)
      end
      
      it 'redirects to the user page' do
        delete :destroy, :id => @harvard.to_param, :cancel => true
        response.should redirect_to(user_path)
      end
    end
  end
  
  describe '#query' do
    context 'when no libraries are returned' do
      it 'assigns no libraries' do
        stub_request(:get, /worldcatlibraries.org\/registry\/lookup.*/).to_return(ResponseExamples.load(:worldcat_response_empty))
        get :query
        assigns(:libraries).should have(0).items
      end
    end
    
    context 'when libraries are returned' do
      it 'assigns the libraries' do
        stub_request(:get, /worldcatlibraries.org\/registry\/lookup.*/).to_return(ResponseExamples.load(:worldcat_response_nd))
        get :query
        assigns(:libraries).should have(1).item
      end
    end
    
    context 'when WorldCat times out' do
      it 'assigns no libraries' do
        stub_request(:get, /worldcatlibraries.org\/registry\/lookup.*/).to_timeout
        get :query
        assigns(:libraries).should have(0).items
      end
    end
  end

end
