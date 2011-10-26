# -*- encoding : utf-8 -*-

# Handles all user login, logout, and options
#
# This controller handles user login (using Janrain Engage), logout, and
# the display and modification of user options.
#
# @see User
class UsersController < ApplicationController
  before_filter :login_required, :only => [ :logout, :update ]

  # Render the users index page
  #
  # This page either shows the options for logged-in users, or redirects
  # to the login form.
  #
  # @api public
  # @return [undefined]
  def show
    redirect_to login_user_path if @user.nil?
  end
  
  # Render the login page
  # @api public
  # @return [undefined]
  def login; end


  # Log out the currently active user
  #
  # This page nulls out the user object in the session, and redirects to
  # the home page.
  #
  # @api public
  # @return [undefined]
  def logout
    @user = nil
    session.delete :user_id
    redirect_to root_path
  end


  # Parse the redirect we get from the Janrain Engage server
  #
  # This page is called automatically by the Janrain Engage service after a
  # user has successfully logged in.  We look up their user account, and
  # either redirect them to the datasets page (if they are a known user), or 
  # render a form on which they can confirm their user account details (if 
  # they are new).
  #
  # @api public
  # @note We can't run tests on this method, as there's no way to mock 
  #   the API interaction with the Janrain server.
  # @return [undefined]
  #:nocov:
  def rpx
    data = {}
    RPXNow.user_data(params[:token], :additional => [:name, :email, :verifiedEmail]) { |raw| data = raw['profile'] }
    @new_user = User.find_or_initialize_with_rpx(data)
    if @new_user.new_record?
      logger.debug "First time we've seen this user, render the form"
      render :template => 'users/new'
    else
      logger.debug "We've seen this user before, redirect to the datasets page"
      reset_session
      session[:user_id] = @new_user.to_param
      @user = @new_user
      redirect_to datasets_path
    end
  end
  #:nocov:

  # Create a new user object
  #
  # This page is called when the users submits the new-user form successfully.
  # It creates the new user object in the database, then redirects to the
  # datasets page (if the user is valid).
  #
  # @api public
  # @return [undefined]
  def create
    @new_user = User.new
    @new_user.name = params[:user][:name]
    @new_user.email = params[:user][:email]
    @new_user.identifier = params[:user][:identifier]
    @new_user.language = params[:user][:language]

    logger.debug "Created new user: #{@new_user.attributes.inspect}"
    logger.debug "User should be valid: #{@new_user.valid?}"
    
    if @new_user.save
      reset_session
      session[:user_id] = @new_user.to_param
      @user = @new_user
      redirect_to datasets_path
    else
      render :template => 'users/new'
    end
  end

  # Update the attributes of a user
  #
  # This page is called by the user options form on the index page.  It
  # simply checks to make sure that the attributes have successfully been
  # updated, or re-renders the form with errors.
  #
  # @api public
  # @return [undefined]
  def update
    user = @user
    if user.update_attributes(params[:user])
      redirect_to user_path
    else
      render "show"
    end
  end
end
