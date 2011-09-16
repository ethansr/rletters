class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def login_required
    if session[:user].nil?
      redirect_to users_path
    end
  end
end
