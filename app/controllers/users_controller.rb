class UsersController < ApplicationController
  def index
  end

  def logout
    session[:user] = nil
    render :action => 'index'
  end

  def rpx
    data = {}
    RPXNow.user_data(params[:token], :additional => [:name, :email, :verifiedEmail]) { |raw| data = raw['profile'] }
    @user = User.find_or_initialize_with_rpx(data)
    if @user.new_record?
      render :action => 'rpx'
    else
      session[:user] = @user
      render :action => 'index'
    end
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      session[:user] = @user
      render :action => 'index'
    else
      render :action => 'new'
    end
  end
end
