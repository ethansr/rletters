# coding: UTF-8


# Controller for exporting a given collection of documents to one of our
# export formats.  Serves as a pass-through to the various +*Collection+
# classes.
class ExportsController < ApplicationController
  
  # Static list of all export formats, connecting a controller action to
  # a class name.
  #
  # A nice piece of metaprogramming in this controller loops over this list,
  # creating a method corresponding to each action which calls the send
  # method on the given class, setting a few HTTP headers along the way.  In
  # this way, adding a new export format is as easy as writing a +Collection+
  # class that responds to <tt>new(documents)</tt> and
  # <tt>send(controller)</tt>, adding it to this list, and adding a route to
  # <tt>config/routes.rb</tt>.
  EXPORT_FORMATS = [
    { :action => "ris", :class => "RISCollection" },
    { :action => "bibtex", :class => "BIBCollection" },
    { :action => "endnote", :class => "EndNoteCollection" },
    { :action => "rdf", :class => "RDFCollection" },
    { :action => "turtle", :class => "TurtleCollection" },
    { :action => "marc", :class => "MARCCollection" },
    { :action => "marcxml", :class => "MARCXMLCollection" },
    { :action => "mods", :class => "MODSCollection" }
  ]
  
  # This may be my favorite bit of Ruby meta-programming I've done yet.
  # There's no way to RDoc this, however.  It is described in the docs for
  # EXPORT_FORMATS above.
  EXPORT_FORMATS.each do |f|
    class_eval <<-RUBY
    def #{f[:action]}
      headers["Cache-Control"] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers["Expires"] = "0"
      
      Kernel.const_get("#{f[:class]}").new(get_documents).send(self)
    end
    RUBY
  end
  
  
  # Show a list of all possible export formats.
  def formats
    @documents = get_documents
    @document_ids = params[:document_id]
  end
  
  
  # Get the set of documents passed into this controller.  If the user wants
  # to export more than one document as a collection (for example, the entire
  # set of results from a search), the identifiers for the documents are
  # comma-separated.
  def get_documents # :doc:
    raise ActiveRecord::RecordNotFound if params[:document_id].blank?
    params[:document_id].split(',').map { |i| Document.find(i)[:document] }
  end
  private :get_documents
end
