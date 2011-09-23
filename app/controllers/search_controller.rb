class SearchController < ApplicationController
  def index
    @documents = Document.find_all_by_solr_query(search_params_to_solr_query, :offset => 0, :limit => 10)
  end

  def results
    @documents = Document.find_all_by_solr_query(search_params_to_solr_query, :offset => 0, :limit => 10)
    render :template => 'search/results', :layout => false
  end

  # Convert from web-query params (one per field) to a set of Solr 
  # query parameters to be passed to <tt>Document.find_all_by_solr_query</tt>.
  def search_params_to_solr_query
    # Treat 'page' and 'per_page' separately
    page = 0
    page = Integer(params[:page]) if params.has_key? :page

    # FIXME: move to user settings if logged in
    per_page = 10
    per_page = Integer(params[:per_page]) if params.has_key? :per_page

    offset = page * per_page
    limit = per_page

    # Remove any blank values (you get these on form submissions, for
    # example)
    params.delete_if { |k, v| v.blank? }

    # Initialize by copying over the faceted-browsing query
    query_params = { :fq => params[:fq] }
    
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
