# -*- encoding : utf-8 -*-

# The main application controller for RLetters
#
# This controller implements functionality shared throughout the entire
# RLetters site.
class ApplicationController < ActionController::Base
  protect_from_forgery

  private
  
  before_filter :get_user, :set_locale, :set_timezone, :ensure_trailing_slash
  
  # Get the user if one is currently logged in
  #
  # We must save only the user's ID, as packing the +datasets+ value into the
  # session table is a big problem.  This filter looks up the user
  # automatically on every page load and saves it as +@user+.  
  # Do not disable it!
  #
  # @api private
  # @return [undefined]
  def get_user
    @user = nil
    return if session[:user_id].nil?
    
    # Don't throw a 404 if someone tries to spoof the user_id, just
    # chomp it silently
    begin
      @user = User.find(session[:user_id])
    rescue ActiveRecord::RecordNotFound
      @user = nil
      session.delete :user_id
    end
  end

  # Set the locale if the user is logged in
  #
  # This function is called as a +before_filter+ in all controllers, you do
  # not need to call it yourself.  Do not disable it, or the locale system
  # will go haywire.
  #
  # @api private
  # @return [undefined]
  def set_locale
    if @user.nil?
      I18n.locale = I18n.default_locale
    else
      I18n.locale = @user.language.to_sym
    end
  end
  
  # Set the timezone if the user is logged in
  #
  # This function is called as a +before_filter+ in all controllers, you do
  # not need to call it yourself.  Do not disable it, or the timezone system
  # will go haywire.
  #
  # @api private
  # @return [undefined]
  def set_timezone
    if @user.nil?
      Time.zone = 'Eastern Time (US & Canada)'
    else
      Time.zone = @user.timezone
    end
  end

  # Redirect to the users page if there is no logged in user
  #
  # This function is intended to serve as an optional +before_filter+ that
  # a controller can use to indicate that only logged-in users should be able
  # to access certain pages.
  #
  # @api private
  # @return [undefined]
  # @example Require login for the "index" action of a controller
  #   before_filter :login_required, :only => [ :index ]
  def login_required
    if @user.nil?
      redirect_to user_path, :rel => :external, :notice => I18n.t('all.login_warning')
    end
  end
  
  # Make sure there's a trailing slash on the URL
  #
  # jQuery Mobile really wants us always to have a trailing slash on our
  # URLs, since we often are redirecting to subdirectory pages (e.g., from
  # /datasets/ to /datasets/2/ to /datasets/2/task/3/results/, etc.).  This
  # helper makes sure we've always got a trailing slash.  Don't disable it!
  #
  # @api private
  # @return [undefined]
  def ensure_trailing_slash
    redirect_to url_for(params.merge(:trailing_slash => true)), :status => 301 unless trailing_slash?
  end

  # Does the REQUEST_URI end with a trailing slash?
  # @api private
  # @return [Boolean] true if request URI ends with /
  def trailing_slash?
    request.env['REQUEST_URI'].match(/[^\?]+/).to_s.last == '/'
  end
end
