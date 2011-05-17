# coding: UTF-8


# Controller allowing the user to follow links to locate a document on other
# online services.
#
# Since finding some of these links (such as Mendeley and citeulike) require
# querying an external server for a piece of JSON, analyzing that JSON, and
# responding to it, we want to separate this out into another controller that
# only fetches those links when the user asks for them.
class LinksController < ApplicationController
  
  # Show a list of all online and library link targets for this
  # document.
  def targets
    @document = Document.find(params[:document_id])[:document]
  end
  
  # Redirect to the appropriate page on Mendeley for this document.
  def mendeley
    @document = Document.find(params[:document_id])[:document]
    
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
  
  # Redirect to the appropriate page on CiteULike for this document.
  def citeulike
    @document = Document.find(params[:document_id])[:document]
    
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
end
