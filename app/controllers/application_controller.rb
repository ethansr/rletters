# -*- encoding : utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def login_required
    if session[:user].nil?
      redirect_to users_path, :rel => :external, :notice => "You must be logged in to view this page."
    end
  end
end
