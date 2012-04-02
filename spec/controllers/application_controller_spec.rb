# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ApplicationController do

  fixtures :users

  describe '#get_user' do
    controller(ApplicationController) do
      def index
        render :nothing => true
      end
    end

    context 'without a user ID' do
      before(:each) do
        session[:user_id] = nil
        get :index
      end

      it 'does not set a user ID' do
        session[:user_id].should_not be
      end

      it 'does not set a user' do
        assigns(:user).should_not be
      end
    end

    context 'with a spoofed user ID' do
      before(:each) do
        session[:user_id] = 31337
        get :index
      end

      it 'removes the spoofed user ID' do
        session[:user_id].should_not be
      end

      it 'does not set a user' do
        assigns(:user).should_not be
      end
    end

    context 'with a good user ID' do
      before(:each) do
        session[:user_id] = users(:john).to_param
        get :index
      end

      it 'leaves the user ID alone' do
        session[:user_id].should eq(users(:john).to_param)
      end

      it 'sets the right user' do
        assigns(:user).should eq(users(:john))
      end
    end
  end

  describe '#set_locale' do
    controller(ApplicationController) do
      def index
        render :nothing => true
      end
    end

    context 'with no user' do
      before(:each) do
        session[:user_id] = nil
        get :index
      end

      it 'leaves locale at default' do
        I18n.locale.should eq(I18n.default_locale)
      end
    end

    context 'with a user' do
      before(:each) do
        session[:user_id] = users(:alice).to_param
        get :index
      end

      it "sets locale to the user's language" do
        I18n.locale.should eq(:'es-MX')
      end
    end
  end

  describe '#set_timezone' do
    controller(ApplicationController) do
      def index
        render :nothing => true
      end
    end

    context 'with no user' do
      before(:each) do
        session[:user_id] = nil
        get :index
      end

      it 'leaves timezone at default' do
        Time.zone.name.should eq('Eastern Time (US & Canada)')
      end
    end

    context 'with a user' do
      before(:each) do
        session[:user_id] = users(:alice).to_param
        get :index
      end

      it "sets timezone to the user's timezone" do
        Time.zone.name.should eq('Mexico City')
      end
    end
  end

  describe '#login_required' do
    controller(ApplicationController) do
      before_filter :login_required
      
      def index
        render :nothing => true
      end
    end

    context 'without a user specified' do
      before(:each) do
        @user = nil
        session[:user_id] = nil
      end

      it 'redirects to user_path' do
        get :index
        response.should redirect_to(user_path)
      end

      it 'sets a warning' do
        get :index
        flash[:notice].should be
      end
    end

    context 'with a user specified' do
      before(:each) do
        @user = users(:john)
        session[:user_id] = @user.to_param
      end

      it 'does not redirect' do
        get :index
        response.should be_success
      end
    end
  end
end
