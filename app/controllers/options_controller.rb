# coding: UTF-8

class OptionsController < ApplicationController
  def index; end
  
  SESSION_VARS = [ :per_page ]
  def setsession
    SESSION_VARS.each { |v|
      raise ActiveRecord::RecordNotFound if params[v].blank? }
    SESSION_VARS.each { |v|
      session[v] = params[v]}
    
    redirect_to root_path
  end
end
