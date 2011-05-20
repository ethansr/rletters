class OptionsController < ApplicationController
  def index; end
  
  def locale
    raise ActiveRecord::RecordNotFound if params[:locale].blank?
    raise ActiveRecord::RecordNotFound unless APP_CONFIG['available_locales'].include? params[:locale]
    
    I18n.locale = params[:locale]
    redirect_to root_path
  end
  
  
  SESSION_VARS = [ :perpage ]
  
  def setsession
    SESSION_VARS.each { |v|
      raise ActiveRecord::RecordNotFound if params[v].blank? }
    SESSION_VARS.each { |v|
      session[v] = params[v]}
    
    redirect_to root_path
  end
end
