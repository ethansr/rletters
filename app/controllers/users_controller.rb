class UsersController < ApplicationController
  def index; end

  def logout
    session[:user] = nil
    redirect_to :action => 'index'
  end

  def rpx
    data = {}
    RPXNow.user_data(params[:token], :additional => [:name, :email, :verifiedEmail]) { |raw| data = raw['profile'] }
    @user = User.find_or_initialize_with_rpx(data)
    if @user.new_record?
      logger.debug "First time we've seen this user, render the form"
      render :template => 'form'
    else
      logger.debug "We've seen this user before, redirect to index"
      session[:user] = @user
      redirect_to :action => 'index'
    end
  end

  def create
    @user = User.new(params[:user])
    logger.debug "Created new user: #{@user.attributes.inspect}"
    logger.debug "User should be valid: #{@user.valid?}"
    
    if @user.save
      session[:user] = @user
      redirect_to :action => 'index'
    else
      render :template => 'form'
    end
  end
end
