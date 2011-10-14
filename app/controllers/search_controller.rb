# -*- encoding : utf-8 -*-

# Search and browse the document database
#
# This controller displays both traditional and advanced search pages, the
# resulting lists of documents, and also handles the detailed display of
# information about a single document.  Its main function is to convert the
# user's provided search criteria into Solr queries for 
# +Document.find_all_by_solr_query+.
#
# @see Document
# @see Document.find_all_by_solr_query
class SearchController < ApplicationController
  
  # Show the main search index page
  #
  # The controller just passes the search parameters through 
  # +search_params_to_solr_query+, then sends this solr query on to the
  # server using +Document.find_all_by_solr_query+.
  #
  # @api public
  # @return [undefined]
  def index
    # Treat 'page' and 'per_page' separately
    page = 0
    page = Integer(params[:page]) if params.has_key? :page

    per_page = 10
    per_page = session[:user].per_page if session[:user]
    per_page = Integer(params[:per_page]) if params.has_key? :per_page

    offset = page * per_page
    limit = per_page

    @documents = Document.find_all_by_solr_query(search_params_to_solr_query(params), :offset => offset, :limit => limit)
  end
  
  # Show an individual document
  # @api public
  # @return [undefined]
  def show
    @document = Document.find(params[:id])
  end
  
  # Show an individual document
  # @api public
  # @return [undefined]
  def export
    @document = Document.find(params[:id])
    
    export_formats = {
      :marc => { 
        :method => lambda { @document.to_marc }, 
        :filename => 'export.marc', :mime => 'application/marc' },
      :marcjson => { 
        :method => lambda { @document.to_marc_json }, 
        :filename => 'export.json', :mime => 'application/json' },
      :marcxml => { 
        :method => lambda { 
            xml = @document.to_marc_xml
            ret = ''
            xml.write(ret, 2)
            ret
          }, :filename => 'export.xml', :mime => 'application/marcxml+xml'},
      :bibtex => { 
        :method => lambda { @document.to_bibtex }, 
        :filename => 'export.bib', :mime => 'application/x-bibtex' },
      :endnote => { 
        :method => lambda { @document.to_endnote },
        :filename => 'export.enw', :mime => 'application/x-endnote-refer' },
      :ris => {
        :method => lambda { @document.to_ris },
        :filename => 'export.ris', :mime => 'application/x-research-info-systems' },
      :mods => {
        :method => lambda { 
          xml = @document.to_mods
          ret = ''
          xml.write(ret, 2)
          ret
        }, :filename => 'export.xml', :mime => 'application/mods+xml' },
      :rdf => {
        :method => lambda { @document.to_rdf_xml },
        :filename => 'export.rdf', :mime => 'application/rdf+xml' },
      :n3 => {
        :method => lambda { @document.to_rdf_n3 },
        :filename => 'export.n3', :mime => 'text/rdf+n3' }
    }
    
    f = {}
    respond_to do |format|
      format.marc { f = export_formats[:marc] }
      format.json { f = export_formats[:marcjson] }
      format.marcxml { f = export_formats[:marcxml] }
      format.bibtex { f = export_formats[:bibtex] }
      format.endnote { f = export_formats[:endnote] }
      format.ris { f = export_formats[:ris] }
      format.mods { f = export_formats[:mods] }
      format.rdf { f = export_formats[:rdf] }
      format.n3 { f = export_formats[:n3] }
      format.all { render :file => Rails.root.join('public', '404.html'), :layout => false, :status => 406 and return }
    end
    
    headers["Cache-Control"] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
    headers["Expires"] = "0"
    send_data(f[:method].call, :filename => f[:filename], 
      :type => f[:mime], :disposition => 'attachment')
  end
  
  # Redirect to the Mendeley page for a document
  # @api public
  # @return [undefined]
  def to_mendeley
    raise ActiveRecord::RecordNotFound if APP_CONFIG['mendeley_key'].blank?
    
    @document = Document.find(params[:id])
    
    begin
      res = Net::HTTP.start("api.mendeley.com") { |http| 
        http.get("/oapi/documents/search/title%3A#{URI.escape(@document.title)}/?consumer_key=#{APP_CONFIG['mendeley_key']}") 
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
  
  # Redirect to the Citeulike page for a document
  # @api public
  # @return [undefined]
  def to_citeulike
    @document = Document.find(params[:id])

    begin
      res = Net::HTTP.start("www.citeulike.org") { |http| 
        http.get("/json/search/all?per_page=1&page=1&q=title%3A%28#{CGI::escape(@document.title)}%29")
      }
      json = res.body
      cul_docs = JSON.parse(json)

      raise ActiveRecord::RecordNotFound unless cul_docs.size

      redirect_to cul_docs[0]["href"]
    rescue
      raise ActiveRecord::RecordNotFound
    end
  end

  # Convert from search parameters to Solr query parameters
  #
  # This function takes the GET parameters passed in to the search and
  # handles converting them to the query format expected by Solr.  Primarily,
  # it is intended to support the advanced search page.
  #
  # @api public
  # @param [Hash] params the Rails params object
  # @return [Hash] Solr-format query parameters
  # @example Convert an advanced search to Solr format
  #   search_params_to_solr_query({ :precise => 'true', :title => 'test' })
  #   # { :qt => 'precise', :q => 'title:(test)' }
  def search_params_to_solr_query(params)
    # Remove any blank values (you get these on form submissions, for
    # example)
    params.delete_if { |k, v| v.blank? }

    # Initialize by copying over the faceted-browsing query
    query_params = {}
    query_params[:fq] = params[:fq] unless params[:fq].nil?
    
    if params.has_key? :precise
      # Advanced search, step through the fields
      query_params[:qt] = 'precise'
      query_params[:q] = "#{params[:q]}"
      
      # Verbatim search fields
      %W(authors volume number pages).each do |f|
        query_params[:q] += " #{f}:(#{params[f.to_sym]})" if params[f.to_sym]
      end

      # Verbatim or fuzzy search fields
      %W(title journal fulltext).each do |f|
        field = f
        field += "_search" if params[(f + "_type").to_sym] and params[(f + "_type").to_sym] == "fuzzy"
        query_params[:q] += " #{field}:(#{params[f.to_sym]})" if params[f.to_sym]
      end

      # Handle the year separately, for range support
      if params[:year_start] or params[:year_end]
        year = params[:year_start]
        year ||= params[:year_end]
        if params[:year_start] and params[:year_end]
          year = "[#{params[:year_start]} TO #{params[:year_end]}]"
        end
        
        query_params[:q] += " year:(#{year})"
      end

      # If there's no query after that, add the all-documents operator
      query_params[:q].strip!
      if query_params[:q].empty?
        query_params[:q] = "*:*"
      end
    else
      # Simple search
      if not params.has_key? :q
        query_params[:q] = "*:*"
        query_params[:qt] = "precise"
      else
        query_params[:q] = params[:q]
      end
    end
    
    query_params
  end
end
