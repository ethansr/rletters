class DocumentsController < ApplicationController
  def index
    # FIXME: configurable per_page, sitewide
    page = params.has_key?(:page) ? Integer(params[:page]) : 1;
    num = params.has_key?(:num) ? Integer(params[:num]) : 10;
    
    @documents = Document.all.paginate(:page => page, :per_page => num)
  end
  
  def show
    @document = Document.find(params[:id], true)
  end
end
