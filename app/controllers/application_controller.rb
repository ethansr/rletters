# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options = {})
    if I18n.locale != I18n.default_locale
      { :locale => I18n.locale }
    else
      { }
    end
  end

  private

  def login_required
    if session[:user].nil?
      redirect_to users_path, :rel => :external, :notice => "You must be logged in to view this page."
    end
  end
end
