class SearchController < ApplicationController
  def query
    num = params.has_key?("num") ? params["num"] : 10;
    page = params.has_key?("page") ? params["page"] : 1;
    
    solr = RSolr.connect :url => "http://localhost:8080/solr"
    @solr_response = solr.paginate page, num, 'select', :params => { :q => 'string' }
  end
end
