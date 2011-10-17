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
    page, per_page = get_pagination_params
    offset = page * per_page
    limit = per_page

    @documents = Document.find_all_by_solr_query(search_params_to_solr_query(params), :offset => offset, :limit => limit)
  end
  
  # Show the advanced search page
  # @api public
  # @return [undefined]
  def advanced; end
  
  # Details of the various formats in which we can export documents
  #
  # This is a hash with the following format:
  #   :mime_type_tag => {
  #     :method => lambda { |doc| doc.to_whatever }, # doc is a Document, should return String
  #     :docs => 'http://www.google.com/' # documentation for format (for unAPI)
  #   },
  EXPORT_FORMATS = {
    :marc => { 
      :method => lambda { |doc| doc.to_marc }, 
      :docs => 'http://www.loc.gov/marc/' },
    :json => { 
      :method => lambda { |doc| doc.to_marc_json }, 
      :docs => 'http://www.oclc.org/developer/content/marc-json-draft-2010-03-11' },
    :marcxml => { 
      :method => lambda { |doc|
          xml = doc.to_marc_xml
          ret = ''
          xml.write(ret, 2)
          ret
        }, :docs => 'http://www.loc.gov/standards/marcxml/'},
    :bibtex => { 
      :method => lambda { |doc| doc.to_bibtex }, 
      :docs => 'http://mirrors.ctan.org/biblio/bibtex/contrib/doc/btxdoc.pdf' },
    :endnote => { 
      :method => lambda { |doc| doc.to_endnote },
      :docs => 'http://auditorymodels.org/jba/bibs/NetBib/Tools/bp-0.2.97/doc/endnote.html' },
    :ris => {
      :method => lambda { |doc| doc.to_ris },
      :docs => 'http://www.refman.com/support/risformat_intro.asp' },
    :mods => {
      :method => lambda { |doc|
        xml = doc.to_mods
        ret = ''
        xml.write(ret, 2)
        ret
      }, :docs => 'http://www.loc.gov/standards/mods/' },
    :rdf => {
      :method => lambda { |doc| doc.to_rdf_xml },
      :docs => 'http://www.w3.org/TR/rdf-syntax-grammar/' },
    :n3 => {
      :method => lambda { |doc| doc.to_rdf_n3 },
      :docs => 'http://www.w3.org/DesignIssues/Notation3.html' }
  }
  
  # Show or export an individual document
  #
  # This action is content-negotiated: if you request the page for a document
  # with any of the MIME types specified in +EXPORT_FORMATS+, you will get
  # a citation export back, as a download.
  #
  # @api public
  # @return [undefined]
  def show
    @document = Document.find(params[:id])

    respond_to do |format|
      format.html { render }
      format.any(*EXPORT_FORMATS.keys) { 
        f = EXPORT_FORMATS[request.format.to_sym]
        send_file f[:method].call(@document), "export.#{request.format.to_sym.to_s}", request.format.to_s
        return
      }
      format.any { render(:file => Rails.root.join('public', '404.html'), :layout => false, :status => 406) and return }
    end
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

  # Get the page and per_page values
  #
  # @api public
  # @return [Array] [Integer(page), Integer(per_page)]
  # @example Get the pagination values
  #   page, per_page = get_page_params
  def get_pagination_params
    page = 0
    page = Integer(params[:page]) if params.has_key? :page

    per_page = 10
    per_page = session[:user].per_page if session[:user]
    per_page = Integer(params[:per_page]) if params.has_key? :per_page

    [ page, per_page ]
  end
  helper_method :get_pagination_params

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

  private

  # Send the given string content to the browser as a file download
  #
  # @api public
  # @param [String] str content to send to the browser
  # @param [String] filename filename for the downloaded file
  # @param [String] mime MIME type for the content
  # @return [undefined]
  def send_file(str, filename, mime)
    headers["Cache-Control"] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
    headers["Expires"] = "0"
    send_data str, :filename => filename, :type => mime, :disposition => 'attachment'
  end
end
