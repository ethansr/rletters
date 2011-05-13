class LinksController < ApplicationController
  
  # Show a list of all online and library link targets for this
  # document
  def targets
    @document = get_document
  end
  
  # Redirect to the appropriate page on Mendeley for this document
  def mendeley
    @document = get_document
    
    begin
      res = Net::HTTP.start("api.mendeley.com") { |http| 
        http.get("/oapi/documents/search/#{URI.escape(@document.title)}?consumer_key=#{APP_CONFIG['mendeley_consumer_key']}") 
      }
      json = res.body
      result = JSON.parse(json)
    
      mendeley_docs = result["documents"]
      raise ActiveRecord::RecordNotFound unless mendeley_docs.size
    
      redirect_to mendeley_docs[0]["mendeley_url"]
    rescue
      raise ActiveRecord::RecordNotFound
    end
  end
  
  # Redirect to the appropriate page on CiteULike for this document
  def citeulike
    @document = get_document
    
    begin
      res = Net::HTTP.start("www.citeulike.org") { |http| 
        http.get("/json/search/all?per_page=1&page=1&q=#{CGI::escape(@document.title)}")
      }
      json = res.body
      cul_docs = JSON.parse(json)
    
      raise ActiveRecord::RecordNotFound unless cul_docs.size
    
      redirect_to cul_docs[0]["href"]
    rescue
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def get_document
    id = params[:id]
    raise ActiveRecord::RecordNotFound if id.blank?
    Document.find(id)[:document]
  end
  private :get_document
end
