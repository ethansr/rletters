# -*- encoding : utf-8 -*-

module UserLoginHelper
  def login_user(user)
    before(:each) do
      session[:user_id] = users(user).to_param
      @user = users(user)
    end

    after(:each) do
      session[:user_id] = nil
      @user = nil
    end
  end

  def logout_user
    before(:each) do
      session[:user_id] = nil
      @user = nil
    end
  end
end

