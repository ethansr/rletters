class DocumentsController < ApplicationController
  before_filter :default_attrs
  def default_attrs
    @no_searchbar = false
  end
  
  def index
    # FIXME: configurable per_page, sitewide
    page = params.has_key?(:page) ? Integer(params[:page]) : 1;
    num = params.has_key?(:num) ? Integer(params[:num]) : 10;
    @documents = Document.search(params).paginate(:page => page, :per_page => num)
  end
  
  def search
    @no_searchbar = true
  end
  
  %W(show).each do |m|
    class_eval <<-RUBY
    def #{m}
      @document = Document.find(params[:id], false)
    end
    RUBY
  end
  
  %W(terms text).each do |m|
    class_eval <<-RUBY
    def #{m}
      @document = Document.find(params[:id], true)
    end
    RUBY
  end
end
