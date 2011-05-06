class ExportController < ApplicationController
  def index
    docs = get_documents
    
    render :text => docs.to_s
  end
  
  def get_documents
    ids = params[:id]
    raise ActiveRecord::RecordNotFound if ids.blank?
    ids = [ ids ] unless ids.is_a? Array
    
    ids.map { |i| Document.find(i)[:document] }
  end
  private :get_documents
end
