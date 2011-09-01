# coding: UTF-8


# Main application controller.
class ApplicationController < ActionController::Base
  # Engage Rails 3's request forgery protection.
  protect_from_forgery
end
