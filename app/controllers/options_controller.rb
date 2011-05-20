class OptionsController < ApplicationController
  def index; end
  
  def locale
    raise ActiveRecord::RecordNotFound if params[:locale].blank?
    raise ActiveRecord::RecordNotFound unless APP_CONFIG['available_locales'].include? params[:locale]
    redirect_to send("root_#{params[:locale]}_path")
  end
  
  def setsession
    raise ActiveRecord::RecordNotFound if params[:key].blank?
    raise ActiveRecord::RecordNotFound if params[:value].blank?
    session[params[:key]] = params[:value]
  end
end
