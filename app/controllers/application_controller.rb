# coding: UTF-8


# Main application controller.
class ApplicationController < ActionController::Base
  # Engage Rails 3's request forgery protection.
  protect_from_forgery
  
  # Add a filter to detect the locale in our URLs.  Provided by the
  # +translate_routes+ gem.
  before_filter :set_locale_from_url
end
