# coding: UTF-8

class UnapiController < ApplicationController
  def index
    if params[:id]
      hash_to_instance_variables Document.find(params[:id], true, nil)
      
      if params[:format]
        get_item params[:id], params[:format]
      else
        render :template => 'unapi/formats.xml.builder', :layout => false, :status => 300, :locals => { :id => params[:id] }
      end
    else
      render :template => 'unapi/formats.xml.builder', :layout => false, :locals => { :id => nil }
    end
  end
  
  def get_item(id, format)
    unless ExportController.method_defined? format.to_sym
      render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 406
    else
      redirect_to :controller => 'export', :action => format, :id => id
    end
  end
end
