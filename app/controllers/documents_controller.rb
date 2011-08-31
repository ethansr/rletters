# coding: UTF-8


# The primary controller, which serves all requests having to do with document
# display and searching.
class DocumentsController < ApplicationController
  before_filter :default_attrs

  # By default, show the search bar in the header.  We only disable it on
  # the advanced search page, where the presence of two separate search
  # methods would be distracting.
  def default_attrs
    @no_searchbar = false
  end
  
  # The primary document index, showing a list of documents, from a flat
  # query to the database, as a result of filtered browsing, or as a set
  # of search results.
  def index
    page = params.has_key?(:page) ? params[:page] : 0;
    if session.has_key?(:per_page)
      per_page = session[:per_page]
    else
      per_page = 10
    end
    
    params[:page] = page
    params[:per_page] = per_page
    
    # Set all the variables
    hash_to_instance_variables Document.search(params)
    @document_ids = @documents.map { |d| d.shasum }.join(',')
    @page = page
    @per_page = per_page
    
    render :layout => 'index'
  end
  
  # The advanced search page.
  def search
    @no_searchbar = true
  end
  
  
  # Common code for all the views that operate on a single document, returning
  # a page of information about that document.  Queries the database to return
  # the document, including its full text, possibly with a highlighting query.
  def get_document # :doc:
    hash_to_instance_variables Document.find(params[:id], true, params[:hl_word])
  end
  private :get_document
  
  # Show the detailed citation information and access links for one document.
  def show; get_document; end
  
  # Get a list of term frequencies for one document.
  def terms; get_document; end
  
  # Get a term concordance for one document.
  def concordance; get_document; end
end
