# -*- encoding : utf-8 -*-

# Work with the library entries belonging to a given user
#
# This controller is responsible for the handling of the library OpenURL
# resolvers that users are allowed to link to their accounts.
#
# @see Library
class LibrariesController < ApplicationController
  before_filter :login_required

  def index
    @libraries = session[:user].libraries
    render :layout => false
  end
  
  def new
    @library = Library.new
    @library.user = session[:user]
    render :layout => 'dialog'
  end

  def edit
    @library = session[:user].libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    render :layout => 'dialog'
  end

  def delete
    @library = session[:user].libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    render :layout => 'dialog'
  end

  def create
    @library = Library.new(params[:library])
    @library.user = session[:user]
    logger.info "params: #{@library.inspect}"

    if @library.save
      session[:user].libraries(true)
      redirect_to user_path, :notice => I18n.t('libraries.create.success')
    else
      render :action => 'new', :layout => 'dialog'
    end
  end
  
  def update
    @library = session[:user].libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    
    if @library.update_attributes(params[:library])
      session[:user].libraries(true)
      redirect_to user_path, :notice => I18n.t('libraries.update.success')
    else
      render :action => 'edit', :layout => 'dialog'
    end
  end
  
  def destroy
    @library = session[:user].libraries.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @library
    
    redirect_to user_path and return if params[:cancel]

    @library.destroy
    session[:user].libraries(true)

    redirect_to user_path
  end
    
  def query
    @libraries = []
    
    begin
      res = Net::HTTP.start("worldcatlibraries.org") { |http| 
        http.get("/registry/lookup?IP=#{request.remote_ip}") 
      }
      doc = REXML::Document.new res.body
      doc.elements.each('records/resolverRegistryEntry') do |entry|
        name = entry.elements['institutionName'].text
        url = entry.elements['resolver/baseURL'].text
        
        @libraries << { :name => name, :url => url }
      end
    rescue
      @libraries = []
    end
    
    render :layout => 'dialog'
  end
end
