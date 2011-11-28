# -*- encoding : utf-8 -*-

# Access bibliographic data using unAPI
#
# This controller enables access to citation data for individual document
# records using the unAPI interface, used most prominently by Zotero (as well
# as other web-based bibliography managers).
class UnapiController < ApplicationController
  
  # Implement all of unAPI
  #
  # If +params[:id]+ is set, return either a list of formats customized for a
  # particular document.  If +params[:id]+ and +params[:format]+ are both set,
  # return the actual document (or a 406 error).  If +params[:id]+ is not set,
  # then show the list of all possible export formats.
  #
  # @api public
  # @return [undefined]
  def index
    if params[:id]
      if params[:format]
        if Document.serializers.has_key? params[:format]
          redirect_to :controller => 'search', :action => 'show', :id => params[:id], :format => params[:format]
        else
          render :file => Rails.root.join('public', '404.html'), :layout => false, :status => 406
        end
      else
        render :template => 'unapi/formats.xml.builder', :layout => false, :status => 300
      end
    else
      render :template => 'unapi/formats.xml.builder', :layout => false
    end
  end
end
