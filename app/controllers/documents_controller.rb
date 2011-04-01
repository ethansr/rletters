class DocumentsController < ApplicationController
  before_filter :default_attrs
  def default_attrs
    @no_searchbar = false
  end
  
  def index
    # FIXME: configurable per_page, sitewide
    page = params.has_key?(:page) ? Integer(params[:page]) : 1;
    num = params.has_key?(:num) ? Integer(params[:num]) : 10;
    
    # Fetch the add and remove facets from the session and the params
    session[:facets] ||= []
    if params.has_key? :add_facet and session[:facets].count(params[:add_facet]) == 0
      session[:facets] << params[:add_facet]
    end
    
    if params.has_key? :remove_facet
      if params[:remove_facet] == "all"
        session[:facets] = []
      else
        session[:facets].delete params[:remove_facet]
      end
    end
    
    # Turn the "facets" parameter into an "fq" parameter for Solr
    params[:fq] = []
    session[:facets].each { |q| params[:fq] << q }
    
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
      hash_to_instance_variables Document.find(params[:id], true)
    end
    RUBY
  end
  
  
  def hash_to_instance_variables(h)
    h.each { |k, v| instance_variable_set "@#{k.to_s}", v }
  end
  private :hash_to_instance_variables
end
