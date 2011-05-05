

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
  
  # All the views that operate on a single document, returning a web page
  %W(show terms concordance text).each do |m|
    class_eval <<-RUBY
    def #{m}
      hash_to_instance_variables Document.find(params[:id], true, params[:hl_word])
    end
    RUBY
  end
  
  # All the views that render in plain text, offering a user download
  %W(bib ris enw rdf ttl marc xml_marc xml_mods).each do |m|
    class_eval <<-RUBY
    def #{m}
      hash_to_instance_variables Document.find(params[:id], true, params[:hl_word])
      
      headers["Pragma"] = "public"
      filename = "evotext.#{m.split('_')[0]}"
      headers["Content-Disposition"] = 'attachment; filename="' + filename + '"'
      headers["Cache-Control"] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers["Expires"] = "0"
      
      case "#{m}".split('_')[0]
      when 'bib'
        mime = 'application/x-bibtex'
      when 'ris'
        mime = 'application/x-research-info-systems'
      when 'enw'
        mime = 'application/x-endnote-refer'
      when 'rdf'
        mime = 'application/rdf+xml'
      when 'ttl'
        mime = 'text/turtle'
      when 'marc'
        mime = 'application/marc'
      when 'xml'
        mime = 'application/xml'
      else
        mime = 'text/plain'
      end
      
      render :layout => false, :content_type => mime
    end
    RUBY
  end
  
  # Redirect to the appropriate page on Mendeley for this document
  def mendeley
    hash_to_instance_variables Document.find(params[:id], true, params[:hl_word])
    
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
    hash_to_instance_variables Document.find(params[:id], true, params[:hl_word])
    
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
  
  
  def hash_to_instance_variables(h)
    h.each { |k, v| instance_variable_set "@#{k.to_s}", v }
  end
  private :hash_to_instance_variables
end
