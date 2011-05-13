# coding: UTF-8



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
    @document_ids = @documents.map { |d| d.shasum }
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
end
