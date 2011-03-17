class DocController < ApplicationController
  def show
    if !params.has_key?("id")
      flash[:error] = "Attempted to load a document without an ID"
      redirect_to :root
    end
    
    solr = RSolr.connect :url => "http://localhost:8080/solr"
    @solr_response = solr.get 'select', :params => { :q => "shasum:#{params["id"]}" }
    
    if @solr_response["response"]["numFound"] == 0
      flash[:error] = "Attempted to load an invalid document"
      redirect_to :root
    end
    
    @doc = @solr_response["response"]["docs"][0]
  end
end
