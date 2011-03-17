class SearchController < ApplicationController
  def query
    num = params.has_key?("num") ? Integer(params["num"]) : 10;
    page = params.has_key?("page") ? Integer(params["page"]) : 1;
    query = params.has_key?("q") ? params["q"] : "*:*";
    
    solr = RSolr.connect :url => "http://localhost:8080/solr"
    @solr_response = solr.paginate page, num, 'select', :params => { :q => query }
    @docs = @solr_response["response"]["docs"]
  end
end
