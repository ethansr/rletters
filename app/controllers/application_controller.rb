# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  def set_locale
    if session[:user].nil?
      I18n.locale = I18n.default_locale
    else
      I18n.locale = session[:user].language.to_sym
    end
  end

  private

  def login_required
    if session[:user].nil?
      redirect_to users_path, :rel => :external, :notice => "You must be logged in to view this page."
    end
  end
end
