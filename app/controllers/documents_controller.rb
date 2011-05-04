

class DocumentsController < ApplicationController
  before_filter :default_attrs
  def default_attrs
    @no_searchbar = false
  end
  
  def index
    # FIXME: configurable per_page, sitewide
    page = params.has_key?(:page) ? Integer(params[:page]) : 1;
    num = params.has_key?(:num) ? Integer(params[:num]) : 10;
    
    # Set all the variables, but then paginate the documents
    hash_to_instance_variables Document.search(params)
    @documents = @documents.paginate(:page => page, :per_page => num)
  end
  
  def search
    @no_searchbar = true
  end
  
  %W(show terms concordance text).each do |m|
    class_eval <<-RUBY
    def #{m}
      hash_to_instance_variables Document.find(params[:id], true, params[:hl_word])
    end
    RUBY
  end
  
  # Redirect to the appropriate page on Mendeley for this document
  def mendeley
    hash_to_instance_variables Document.find(params[:id], true, params[:hl_word])
    res = Net::HTTP.start("api.mendeley.com") { |http| 
      http.get("/oapi/documents/search/#{URI.escape(@document.title)}?consumer_key=#{APP_CONFIG['mendeley_consumer_key']}") 
    }
    json = res.body
    result = ActiveSupport::JSON.decode(json)
    
    mendeley_docs = result["documents"]
    raise ActiveRecord::RecordNotFound unless mendeley_docs.size
    
    redirect_to mendeley_docs[0]["mendeley_url"]
  end
  
  
  def hash_to_instance_variables(h)
    h.each { |k, v| instance_variable_set "@#{k.to_s}", v }
  end
  private :hash_to_instance_variables
end
