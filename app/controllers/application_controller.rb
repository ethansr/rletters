# -*- encoding : utf-8 -*-

# The main application controller for RLetters
#
# This controller implements functionality shared throughout the entire
# RLetters site.
class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  before_filter :set_locale
  
  # Set the locale if the user is logged in
  #
  # This function is called as a =before_filter= in all controllers, you do
  # not need to call it yourself.  Do not disable it, or the locale system
  # will go haywire.
  #
  # @api private
  # @return [undefined]
  def set_locale
    if session[:user].nil?
      I18n.locale = I18n.default_locale
    else
      I18n.locale = session[:user].language.to_sym
    end
  end

  # Redirect to the users page if there is no logged in user
  #
  # This function is intended to serve as an optional =before_filter= that
  # a controller can use to indicate that only logged-in users should be able
  # to access certain pages.
  #
  # @api private
  # @return [undefined]
  # @example Require login for the "index" action of a controller
  #   before_filter :login_required, :only => [ :index ]
  def login_required
    if session[:user].nil?
      redirect_to users_path, :rel => :external, :notice => I18n.t('all.login_warning')
    end
  end
end
